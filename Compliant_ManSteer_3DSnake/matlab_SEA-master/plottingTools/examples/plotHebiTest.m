function plotHebiTest()
%Plots and animnates a large manipulator moving all joints from their
%negative to positive limits

    num_links = 10;
    num_samples = 200;
    angles = [];
    plt = HebiPlotter('resolution', 'low');
    for i=1:num_links
        angles = [angles, linspace(-pi/2, pi/2, num_samples)'];
    end
    
    for i=1:num_samples
        plt.plot(angles(i,:));
    end
    

end
