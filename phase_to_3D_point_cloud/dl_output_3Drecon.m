% Multi exposure version
%% Set parameters

clear; clc; close all;

% FPP settings
num_f = 4;
num_step = 12;
HIGHrLOW = [4,4,4];
extension = '.bmp';

% Add the subfunction path.
addpath('.\functions');

% Map the test sequence number back to the initial sequence number
[~, ind] = textread('.\test_Statue_1605_indices_formatted.txt','%n%n','delimiter','-');

%%%%%The absolute phase paths predicted by multiple networks.
root_path1={'.\Resnet34_danet',...
    '.\resnet101',...
    '.\dls_resnet34_danet',...
    '.\resnet34',...
    '.\resnet50',...
    '.\statue_1605'
    };


for i = 1:length(root_path1) %%choose the network using i

    root_path = root_path1{i};

    switch i
        case 1
            A = 'Resnet34_danet';
        case 2
            A = 'resnet101';
        case 3
            A = 'ds_resnet34_danet';
        case 4
            A = 'resnet34';
        case 5
            A = 'resnet50';
        case 6
            A = 'UNet';
        otherwise
            error('unknown model: %s', modelName);
    end


    %%path of CPSD mask
    mask_root ='.\test_mask';


    %The path of the system calibration lookup table
    lut_path = '.\LUTs\LUT_PSP_4.mat';

    %Point cloud save path

    filepath_figure='.\pointcloud_map\';
    dis_save_dir =[filepath_figure, '\recon_special\'];
    % check the path
    if ~exist(dis_save_dir, 'dir')

        mkdir(dis_save_dir);
    end
    for k =1:1
        zmin=870;
        zmax=915;
        phase_path = fullfile(root_path, 'test','\',sprintf('%06d-results.mat', k));
        mask_path = fullfile(mask_root, sprintf('%d.mat', ind(k)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%from phase to 3D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [data_output, data_gt,filtered_output,input] = phase2pc(lut_path, phase_path,mask_path,zmin,zmax);

        ptCloud_output = pointCloud(data_output);
        ptCloud_gt = pointCloud(data_gt);
        filtered_output = pointCloud(filtered_output);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Display and save the output point cloud%%%%%%
        figure;
        pcshow(ptCloud_output);title(['output-3D point cloud-', num2str(k)], 'FontSize', 14, 'Color', 'w');
        colormap(jet);
        dis_save_dir = [dis_save_dir,num2str(k), '\'];

        if ~exist(dis_save_dir, 'dir')
            mkdir(dis_save_dir);
        end


        filename = sprintf('output_3D_%s.ply', A);
        filepath = fullfile(dis_save_dir, filename);

        azimuth = 0;
        elevation = -90;
        view(azimuth, elevation);
        zm=1.2;
        camzoom(zm);
        caxis([zmin zmax]);
        h = colorbar;
        set(h, 'Color', 'w');

        pcwrite(ptCloud_output, filepath);

        fig = gcf;

        ax = gca;
        ax.FontSize = 14;
        ax.XColor = 'w';
        ax.YColor = 'w';
        ax.ZColor = 'w';
        ax.FontName = 'Times New Roman';

        xlabel('X (mm)', 'FontSize', 14, 'Color', 'w', 'FontName', 'Times New Roman');
        ylabel('Y (mm)', 'FontSize', 14, 'Color', 'w', 'FontName', 'Times New Roman');
        zlabel('Z (mm)', 'FontSize', 14, 'Color', 'w', 'FontName', 'Times New Roman');

        set(fig, 'Color', 'k');
        filename = sprintf('output_3D_%s.png', A);

        filepath_figure2= [filepath_figure,num2str(k), '\'];

        if ~exist(filepath_figure2, 'dir')
            mkdir(filepath_figure2);
        end


        saveas(fig, fullfile(filepath_figure2, filename), 'png');
        exportgraphics(fig, fullfile(filepath_figure2, filename), 'BackgroundColor', 'k');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end












