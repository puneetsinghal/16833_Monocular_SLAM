function plotHebiManipulatorTest()
%Plots a simple HEBI linkage with elbow modules and strait modules
    close all;
    links = {{'FieldableElbowJoint'},
             {'FieldableStraightLink', 'ext1', .1, 'twist', pi/2},
             {'FieldableElbowJoint'},
             {'FieldableStraightLink', 'ext1', .1, 'twist', 0}};
    plt = HebiPlotter('JointTypes', links);
    
    num_samples = 200;
    angles = [];

    for i=1:2
        angles = [angles, linspace(-pi/2, pi/2, num_samples)'];
    end
    
    for i=1:num_samples
        plt.plot(angles(i,:));
    end

        
end
