/*
 *  make_snake_fast.cpp
 *  
 *  Created by David Rollinson on 5/25/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 *  This is a Matlab MEX implementation of make_snake.m
 */

/*************************************
 * Documentation from MATLAB version *
 *************************************/

// MAKE_SNAKE
// [module_frame] = make_snake(x_angles, y_angles, x_dofs, y_dofs, module_len)
//   
// Given vectors of angles (module angles), this function returns 
// a set of 4x4 transformations to move points from the frame of the first 
// module to the rest (all the modules are in a single frame from module 1).
//
// Modules are chained in the -z direction, like on the real snake (i.e.
// module 1 is the head, and if the snake were straight, module 2 would be
// behind it along the z-axis.
//
// Inputs: 
//   x_angles / y_angles - Angles (in radians) between each module around
//   the x- and y-axes of the snake as defined by the torsion-free frame
//   convention.  This is usually a full set of angles returned by a
//   gait equations
//
//   module_dofs - A mask to elimate degrees of freedom at the joints so
//   that the angles reflect the configuration of a Unified Snake.
//
//   module_len - The distance between modules joints.  For the unified
//   snake this number is 2.01 inches.  The function defaults to this value
//   if a module length is not specified.
//
// Outputs:
//   module_frame - a [4 x 4 x number of modules] array of homogeneous
//   transform matrices describing the shape of the the centers of each of
//   the modules in the snake.  There will be 1 more module than angles,
//   since the angles represent joints between modules.
//
//   The shape will returned in a coordinate frame aligned with the position
//   and orientation of the head module.
//
//   ALL UNITS ARE IN RADIANS / INCHES.

/* END MATLAB DOCUMENTATION */

								   
#include "mex.h"
#include <math.h>
#include <Eigen/Dense>
//#include <omp.h>

using namespace Eigen;


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray *prhs[] )
{
    /*************
     * VARIABLES *
     *************/
    int i, j, k;		    // for-loop counters
    int m, n;			    // rows / cols variables
    int output_dims[] = {4,4,0};    // dimensions for the output transforms
    
    int num_modules;		    // number of modules

    double *x_angles = mxGetPr(prhs[0]);	// array of x-joint angles
    double *y_angles = mxGetPr(prhs[1]);	// array of y-joint angles
    
    bool *x_dofs = mxGetLogicals(prhs[2]);	// logical mask for the x-angle DOFs
    bool *y_dofs = mxGetLogicals(prhs[3]);	// logical mask for the y-angle DOFs
    
    double module_len = *mxGetPr(prhs[4]);	// distance between joints of the snake
    
    double *snake_transforms;
    
    
    /*****************************************
     * Size the mxArray for the output data, *
     * based on the input x_angles           *
     *****************************************/
    num_modules = mxGetM(prhs[0]) + 1;
    output_dims[2] = num_modules;
    
    /******************************************
     * Create an mxArray for the output data, *
     * and get a pointer to the data          *
     ******************************************/
    plhs[0] = mxCreateNumericArray(3, output_dims, mxDOUBLE_CLASS, mxREAL);
    snake_transforms = mxGetPr(plhs[0]);
    
    
    /************************************************
     * Create an Eigen Matrices for doing the maths *
     ************************************************/
    
    // The module we care about at each step
    Matrix4d this_module = Matrix4d::Identity();
    
    // Rotation Transforms
    Matrix4d T_Rx = Matrix4d::Identity();
    Matrix4d T_Ry = Matrix4d::Identity();
    
    // Translation Transform 
    // (always 1/2 module length in -z direction of the local frame)
    Matrix4d T_z = Matrix4d::Identity();
    T_z(2,3) = -module_len / 2;
    

    
    /***********************************************
     * Copy the first Eigen Matrix to the MexArray *
     ***********************************************/
    for (j = 0; j < 4; j++)
    {
        for (k = 0; k < 4; k++)
        {
            snake_transforms[4*j + k] = this_module(k,j);
        }
    }
    
    /*******************************************************
     * Chain up the rest and copy values into the mexArray *
     *******************************************************/
    //#pragma omp parallel for
    for (i = 0; i < num_modules-1; i++)
    {	
        // For reference:
        //
        // Rx         Ry         Rz
        // 1  0  0    c  0  s    c -s  0
        // 0  c -s    0  1  0    s  c  0
        // 0  s  c   -s  0  c    0  0  1

        /*************************************
         * Translate by half a module length *
         *************************************/
        this_module = this_module * T_z;

        /*********************
         * Rotate by x_angle *
         *********************/
        if (x_dofs[i])
        {    
            T_Rx <<  1,		0,		0,	       0,
                 0, cos(-x_angles[i]), -sin(-x_angles[i]), 0, 
                 0, sin(-x_angles[i]),  cos(-x_angles[i]), 0,
                 0,		0,		0,	       1;

            this_module = this_module * T_Rx;
        }

        /*********************
         * Rotate by y_angle *
         *********************/
        if (y_dofs[i])
        {    
            T_Ry <<  cos(-y_angles[i]),	0, sin(-y_angles[i]), 0,
                    0,		1,	0,	      0, 
                -sin(-y_angles[i]), 0, cos(-y_angles[i]), 0,
                    0,		0,	0,	      1;

            this_module = this_module * T_Ry;
        }

        /************************************
         *Translate by half a module length *
         ************************************/
        this_module = this_module * T_z;	

        /*****************************************
         * Copy the Eigen Matrix to the MexArray *
         *****************************************/
        for (j = 0; j < 4; j++)
        {
            for (k = 0; k < 4; k++)
            {
            snake_transforms[(i+1)*16 + 4*j + k] = this_module(k,j);
            }
        }
    }
    
}



