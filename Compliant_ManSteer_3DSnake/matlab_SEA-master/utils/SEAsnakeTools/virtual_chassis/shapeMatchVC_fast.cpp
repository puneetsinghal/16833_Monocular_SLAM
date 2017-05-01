/*
 *  shapeMatchVC_fast.cpp
 *  
 *  Created by David Rollinson on 8/9/13.
 *
 *  This is a Matlab MEX implementation of the 'shape matching' virtual 
 *  chassis.  It takes in two shapes of the snake robot, and matches the
 *  second to the first, solving "Wahba's problem" w/ SVD.  Wikipedia those
 *  terms for more info.
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
//       currentFrames - a [4 x 4 x number of modules] array of homogeneous
//       transform matrices describing the poses of the the centers of 
//       the modules in the robot.  The matrices need to be in some common
//       body frame, not relative to each other.
//
//       lastFrames - a [4 x 4 x number of modules] array of homogeneous
//       transform matrices describing the poses of the the centers of 
//       the modules in the robot from a previous timestep.  This function
//       will find the transform that best aligns the current shape with 
//       this one.
//
//   Outputs:
//       virtualChassis - [4 x 4] transformation matrix that describes the
//       pose of the virtual chassis body frame, described in the frame of
//       the input transformation matrices.
//
//   Dave Rollinson
//   Aug 2013

/* END MATLAB DOCUMENTATION */

								   
#include "mex.h"
#include <math.h>
#include <iostream>
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

    double *currentFrames = mxGetPr(prhs[0]);  // input transforms (4 x 4 x N)
    double *lastFrames;
    
    double *virtualChassis;	// virtual chassis transform (4 x 4)
    double *xyz;            // center of mass of the robot modules (3 x 1)
    
    
    /********************************************
     * Get the number of modules for the loops. *
     ********************************************/
    inputDims = mxGetDimensions(prhs[0]);
    numModules = inputDims[2];  // 4 x 4 x n  <---- n is number of modules
    
    
    /******************************************
     * Create mxArrays for the output data,   *
     * and get pointers to the data.          *
     ******************************************/
    plhs[0] = mxCreateDoubleMatrix(4, 4, mxREAL);
    virtualChassis = mxGetPr(plhs[0]);
    
    if (nrhs > 1) 
    {
        lastFrames = mxGetPr(prhs[1]);  // Use last shape
    }
    else
    {
        lastFrames = currentFrames;     // Copy last shape
    }
    
    
    /*********************************************
     * Create Eigen Matrices for doing the maths *
     *********************************************/
    
    // Matrix for the virtual chassis transform
    Matrix4d VC = Matrix4d::Identity();
    
    // Form the data matrix for doing SVD
    MatrixXd xyz_ptsNow(numModules,3);
    MatrixXd xyz_ptsLast(numModules,3);
    
    for (i = 0; i < numModules; i++)
    {
        // Copy the x,y,z coordinates from currentFrames
        xyz_ptsNow(i,0) = currentFrames[16*i + 12];
        xyz_ptsNow(i,1) = currentFrames[16*i + 13];
        xyz_ptsNow(i,2) = currentFrames[16*i + 14];
        
        // Copy the x,y,z coordinates from lastFrames
        xyz_ptsLast(i,0) = lastFrames[16*i + 12];
        xyz_ptsLast(i,1) = lastFrames[16*i + 13];
        xyz_ptsLast(i,2) = lastFrames[16*i + 14];
    }
    
    
    // Get the center of mass of the module positions.
    // Subtract it from the xyz positions
    Vector3d CoM_now = xyz_ptsNow.colwise().mean();
    Vector3d CoM_last = xyz_ptsLast.colwise().mean();
    
    for (j = 0; j < 3; j++)
    { 
        xyz_ptsNow.col(j).array() -= CoM_now(j);
        xyz_ptsLast.col(j).array() -= CoM_last(j);
    }
    
    
    /************************************
     * Take the SVD to align the shapes *
     ************************************/
    
    // Make a correlation matrix from the 2 shapes
    // This should be a 3x3 matrix
    Matrix3d xyzCorr = xyz_ptsLast.transpose() * xyz_ptsNow;
    
    // std::cout << xyzCorr;

    // Take the SVD
    JacobiSVD<Matrix3d> svd(xyzCorr, ComputeThinU | ComputeThinV);
    
    // Get the singular values and V matrix
    Matrix3d U = svd.matrixU();
    Matrix3d V = svd.matrixV();
    
    
    /*********************************************
    * Make sure resulting matrix is right-handed *
    **********************************************/
    Matrix3d S = Matrix3d::Identity();
    
    // Check the determinant
    double detCheck = (U*V).determinant();
    
    if (detCheck > 0.0)
    {
        S(2,2) = 1.0;
    }
    else
    {
        S(2,2) = -1.0;
    }
    
    // Get the optimal rotation to align the shapes
    Matrix3d R = V*S*U.transpose();
            
    // 4x4 transform for the virtual chassis
    VC.block<3,3>(0,0) = R;
    VC.block<3,1>(0,3) = CoM_now;
    
    
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
    
}



