/*
 *  transform_snake_fast.cpp
 *  
 *  Created by David Rollinson on 5/26/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 *  This is a Matlab MEX implementation of transform_snake.m
 */

/*************************************
 * Documentation from MATLAB version *
 *************************************/

// TRANSFORM_SNAKE
// [new_module_frames] = transform_snake(module_frames, T)
//   
// Given a shape of the snake in the form of a set of homogeneous transforms, 
// (4x4xN) and a new homogeneous transform describing a new body frame (4x4),
// the snake is transformed to the new body frame.
//
// For example: if T describes the pose of some module in module_frames,
// calling this function will shift the body frame of the snake to be
// aligned with the frame fixed at that module.
//
// Inputs: 
//   module_frames - a [4 x 4 x number of modules] array of homogeneous
//   transform matrices describing the shape of the the centers of each of
//   the modules in the snake.  The matrices need to be in some global
//   body frame, not relative to each other.
//
//   T - a homogeneous transform in the current body frame describing the
//   the pose of the new body frame relative to the current one.
//
// Outputs:
//   new_module_frames - a [4 x 4 x number of modules] array of homogeneous
//   transform matrices describing the shape of the the centers of each of
//   the modules in the snake.
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
    int i, j, k;		// for-loop counters
    int m, n;			// rows / cols variables
    const int *output_dims;	// dimensions for the output transforms
    
    int num_modules;		// number of modules

    double *snake_frames = mxGetPr(prhs[0]);    // input transforms (4 x 4 x N)
    double *body_frame = mxGetPr(prhs[1]);	// body frame transform (4 x 4)
    
    double *output_frames;	// new module transforms
    
    
    /*******************************************
     * Size the mxArray for the output data,   *
     * based on the length of the input array. *
     *******************************************/
    output_dims = mxGetDimensions(prhs[0]);
    num_modules = output_dims[2];
    
    /******************************************
     * Create an mxArray for the output data, *
     * and get a pointer to the data          *
     ******************************************/
    plhs[0] = mxCreateNumericArray(3, output_dims, mxDOUBLE_CLASS, mxREAL);
    output_frames = mxGetPr(plhs[0]);
    
    /************************************************
     * Create an Eigen Matrices for doing the maths *
     ************************************************/
    
    // The module we care about at each step
    Matrix4d this_module = Matrix4d::Identity();
    
    // The transform describing the new body frame
    Matrix4d T = Matrix4d::Identity();
    for (j = 0; j < 4; j++)
    {
        for (k = 0; k < 4; k++)
        {
            T(k,j) = body_frame[4*j + k];
        }
    }
    
    // Invert the new body frame
    Matrix4d T_inv = T.inverse();
    
    /*******************************************************
     * Step thru all the modules, transform the frame,     *
     * and copy values into the mexArray.                  *
     *******************************************************/
    //#pragma omp parallel for
    for (i = 0; i < num_modules; i++)
    {		
        /************************************************
         * Create an Eigen Matrix for the module frame, *
         ************************************************/
        Matrix4d this_module = Matrix4d::Identity();
        for (j = 0; j < 4; j++)
        {
            for (k = 0; k < 4; k++)
            {
                this_module(k,j) = snake_frames[(i*16) + (4*j) + k];
            }
        }

        /************************************
         *Transform into the new body frame *
         ************************************/
        this_module = T_inv * this_module;	

        /*****************************************
         * Copy the Eigen Matrix to the MexArray *
         *****************************************/
        for (j = 0; j < 4; j++)
        {
            for (k = 0; k < 4; k++)
            {
                output_frames[(i*16) + (4*j) + k] = this_module(k,j);
            }
        }
    }

}



