function [ data_output,data_gt,filtered_data,input] = phase2pc(LUT_path, phase_path, mask_path, zmin, zmax)

    LUT_Poly_Struct = load(LUT_path);
    LUT_Poly = LUT_Poly_Struct.LUT_Poly;
    [~, ~, im_w, im_h] = size(LUT_Poly);
    
       mask1 = load(mask_path);
       mask=mask1.mask_save;

    if size(phase_path, 1) == im_h%
        phase = phase_path';
    elseif size(phase_path, 1) == im_w%
        phase = phase_path;
    else
        tmp = load(phase_path);

   
        if isfield(tmp, 'output_unwrap')

            phase= tmp.output_unwrap';
        else

            phase= tmp.output1';
        end   

        phase=phase*400;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Restore the true phase value


        if isfield(tmp, 'gt_unwrap')
            phase_gt = tmp.gt_unwrap';
        else
            phase_gt = tmp.gt1';
        end        

        phase_gt=phase_gt*400;

        if isfield(tmp, 'input')
            input= tmp.input';
        else
            input= tmp.input1';
        end   

    end




mask=mask';


%%% output point cloud
    for v_idx=77:524
        for u_idx=113:688

            tempIdx = im_w*(v_idx-1)+u_idx;
            if mask(u_idx-112,v_idx-76) == 1
                p1 = phase(u_idx-112,v_idx-76);%448*576
                p2 = p1*p1;
                p3 = p1*p2;
                ps = [1; p1;p2;p3];
                
                for k = 1:3
                    data(tempIdx,k) = LUT_Poly(k,:,u_idx,v_idx)*ps;
                end
            else
                data(tempIdx, :) = nan;
            end
        end
    end
    data(all(data==0,2),:) = [];
    data(data(:, 3) > zmax | data(:, 3) < zmin, :) = [];

    data_output = data(all(~isnan(data), 2), :);    


filtered_data = smoothdata(data_output,'movmedian',15);





%%ground truth point cloud
    data_gt=zeros(im_h*im_w,3);%imh=600,imw=800
 for v_idx=77:524
        for u_idx=113:688

            tempIdx_gt = im_w*(v_idx-1)+u_idx;
            if mask(u_idx-112,v_idx-76) == 1
                p1 = phase_gt(u_idx-112,v_idx-76);%448*576
                p2 = p1*p1;
                p3 = p1*p2;
                ps = [1; p1;p2;p3];
                
                for k = 1:3
                    data_gt(tempIdx_gt,k) = LUT_Poly(k,:,u_idx,v_idx)*ps;
                end
            else
                data_gt(tempIdx_gt, :) = nan;
            end
        end
  end
    data_gt(all(data_gt==0,2),:) = []; 
    data_gt(data_gt(:, 3) > zmax | data_gt(:, 3) < zmin, :) = [];

    data_gt = data_gt(all(~isnan(data_gt), 2), :);   


end