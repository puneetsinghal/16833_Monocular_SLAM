/*
 *  unifiedVC_fast.cpp
 *  
 *  Created by David Rollinson on 9/4/11.
 *
 *  This is a Matlab MEX implementation of unifiedVC.m
 */

/*************************************
 * Documentation from MATLAB version *
 *************************************/

//UNIFIEDVC
//   [ virtualChassis, chassisMags ] = 
//			unifiedVC( robotFrames, axisPerm, lastVC )
//
//   Uses SVD to find the virtual chassis of the snake for any gait.  
//   The function finds the principal moments of inertia of the robot's 
//   shape and uses them to define the axes of the virtual chassis, with the
//   origin at the center of mass (each transform is treated as a point mass
//   of equal weight).
//
//   This code is intended for use with the Modsnake robots, but it should
//   theoretically be general enough to work on any system with a bunch of
//   rigid bodies described by transformation matrices in a common frame.
//
//   Inputs:
//       robotFrames - a [4 x 4 x number of modules] array of homogeneous
//       transform matrices describing the poses of the the centers of 
//       the modules in the robot.  The matrices need to be in some common
//       body frame, not relative to each other.
//
//       axisPerm - a [3 x 3] permutation matrix that allows the user to
//       re-align the virtual chassis however they want.  By default the 
//   	 1st, 2nd, and 3rd principal moments of inertia are aligned
//       respectively with the Z, Y, and X axes of the virtual chassis.
//
//       lastVC - this is optional and is used to correct for sign flipping
//       that can occur due to the SVD algorithm.  If lastVC is passed in,
//       then the virtual chassis will not flip signs with respect to this
//       frame.  We assume that a similar initial frame was used to generate
//       the virtual chassis at both this configuration and lastVC.  By 
//       default the principal axis of the virtual chassis will point toward
//       the module specified by the first transform in robotFrames.  
//
//   Outputs:
//       virtualChassis - [4 x 4] transformation matrix that describes the
//       pose of the virtual chassis body frame, described in the frame of
//       the input transformation matrices.
//
//       chassisMags - [3 x 1] vector, diag(S) from SVD, used for reporting
//       the magnitudes of the principle components of the robot's shape.
//
//   Dave Rollinson
//   July 2011

/* END MATLAB DOCUMENTATION */

								   
#include "mex.h"
#include <math.h>
#include <Eigen/Dense>
#include <Eigen/Core>
//#include <omp.h>

using namespace Eigen;


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray *prhs[] )
{
    /*************
     * VARIABLES *
     *************/
    int i, j, k;		// for-loop counters
    int m, n;			// rows + cols variables
    const int *inputDims;	// dimensions for the input transforms
    double signCheck;   // for checking for sign-flips in the VC
    
    int numModules;		// number of modules

    double *robotFrames = mxGetPr(prhs[0]);    // input transforms (4 x 4 x N)
    double *axisPerm = mxGetPr(prhs[1]);	// axis permutation matrix (3 x 3)
    double *lastVC;
    
    if (nrhs > 2) 
    {
        lastVC = mxGetPr(prhs[2]);      // previous VC, (4 x 4)
    }
    
    double *virtualChassis;	// virtual chassis homogeneous transform (4 x 4)
    double *chassisMags;    // vector of the singular values from SVD
    
    double *xyz;            // center of mass of the robot modules 
    
    
    /********************************************
     * Get the number of modules for the loops. *
     ********************************************/
    inputDims = mxGetDimensions(prhs[0]);
    numModules = inputDims[2];
    
    
    /******************************************
     * Create mxArrays for the output data,   *
     * and get pointers to the data.          *
     ******************************************/
    plhs[0] = mxCreateDoubleMatrix(4, 4, mxREAL);
    virtualChassis = mxGetPr(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);
    chassisMags = mxGetPr(plhs[1]);
    
    
    /*********************************************
     * Create Eigen Matrices for doing the maths *
     *********************************************/
    
    // Matrix for the virtual chassis transform
    Matrix4d VC = Matrix4d::Identity();
    
    // Form the data matrix for doing SVD
    MatrixXd xyz_pts(numModules,3);
    for (i = 0; i < numModules; i++)
    {
        // Copy the x,y,z coordinates from robotFrames
        xyz_pts(i,0) = robotFrames[16*i + 12];
        xyz_pts(i,1) = robotFrames[16*i + 13];
        xyz_pts(i,2) = robotFrames[16*i + 14];
    }
    
    // Get the center of mass of the module positions.
    // Subtract it from the xyz positions
    Vector3d CoM = xyz_pts.colwise().mean();
    for (j = 0; j < 3; j++)
    { 
        xyz_pts.col(j).array() -= CoM(j);
    }
    
    // Matrix for axis permutation
    Matrix3d aPerm = Matrix3d::Identity();
    for (j = 0; j < 3; j++)
    {
        for (k = 0; k < 3; k++)
        {
            aPerm(k,j) = axisPerm[3*j + k];
        }
    }
    
    
    /*********************************************
     * Take the SVD of the zero-meaned positions *
     *********************************************/

    // Take the SVD, use thinSVD since we only need V and S.
    JacobiSVD<MatrixXd> svd(xyz_pts, ComputeThinU | ComputeThinV);
    
    // Get the singular values and V matrix
    Vector3d S = svd.singularValues();
    Matrix3d V = svd.matrixV();
    
    /****************************************
     * If there's no previous VC to compare *
     ****************************************/
    if (nrhs < 3) 
    {
        // Make sure the 1st principal moment points toward the
        // head module.
        signCheck = V.col(0).dot( xyz_pts.row(0) );
        if (signCheck < 0)
        {
            V.col(0) = -V.col(0);
        }
        
        // Ensure a right-handed frame, by making the 3rd moment
        // the cross product of the first two.
        V.col(2) = V.col(0).cross(V.col(1));
        
        // Permute the axes and singular values according to axisPerm
        V = V * aPerm;
        S = S.transpose() * aPerm;
    }
    /**********************************************
     * If a previous Virtual Chassis is passed in *
     **********************************************/
    else
    {
        // Get the DCM from the last Virtual Chassis transform
        // Hard-coded because I'm lazy.
        Matrix3d lastVC_R = Matrix3d::Identity();
        lastVC_R(0,0) = lastVC[0];
        lastVC_R(1,0) = lastVC[1];
        lastVC_R(2,0) = lastVC[2];
        lastVC_R(0,1) = lastVC[4];
        lastVC_R(1,1) = lastVC[5];
        lastVC_R(2,1) = lastVC[6];
        lastVC_R(0,2) = lastVC[8];
        lastVC_R(1,2) = lastVC[9];
        lastVC_R(2,2) = lastVC[10];
        
        // Permute the axes and singular values according to axisPerm
        V = V * aPerm;
        S = S.transpose() * aPerm;

        // Make sure x-axis isn't flipped from the last frame.
        signCheck = V.col(0).dot( lastVC_R.col(0) );
        if (signCheck < 0)
        {
            V.col(0) = -V.col(0);
        }
        
        // Make sure y-axis isn't flipped from the last frame.
        signCheck = V.col(1).dot( lastVC_R.col(1) );
        if (signCheck < 0)
        {
            V.col(1) = -V.col(1);
        }
        
        // Ensure a right-handed frame, by making the 3rd moment
        // the cross product of the first two.
        V.col(2) = V.col(0).cross( V.col(1) );
    }
 
    // 4x4 transform for the virtual chassis
    VC.block<3,3>(0,0) = V;
    VC.block<3,1>(0,3) = CoM;
    
    
    /********************************************
     * Copy the Eigen Matrices to the MexArrays *
     ********************************************/
    
    // Matrix for the last virtual chassis
    for (j = 0; j < 4; j++)
    {
        for (k = 0; k < 4; k++)
        {
            virtualChassis[4*j + k] = VC(k,j);
        }
    }
    
    // Copy the singular values into a mxArray
    for (j = 0; j < 3; j++)
    {
        chassisMags[j] = S(j);
    }
    
}



