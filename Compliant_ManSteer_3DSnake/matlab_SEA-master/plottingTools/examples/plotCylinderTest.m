function plotCylinderTest
%Plots the snake as a cylinder, no animation.
%THIS WILL NOT WORK UNLESS YOU ADD "virtual_chassis" TO YOUR PATH

    close all
    plt = CylinderPlotter();

    kin = HebiKinematics;
    kin.addBody('FieldableElbowJoint');
    kin.addBody('FieldableElbowJoint');
    kin.addBody('FieldableElbowJoint');
    kin.addBody('FieldableElbowJoint');
    kin.addBody('FieldableElbowJoint');
    kin.addBody('FieldableElbowJoint');
    
    angles = [.1,.2,-.1,-.3,.1,.2];

    fk = kin.getFK('CoM',angles);
    VC = unifiedVC(fk, eye(3));

    plt.setBaseFrame(inv(VC));
    plt.plot(angles);
    
end