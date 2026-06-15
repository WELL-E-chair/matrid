function r = track_cow_dt(video,cow_gs,start,delta_frame)

% video = hangle to current video
% cow_gs = structure array containing cow datasets
% start = starting frame in the video (when cow of interest appears)

% Lets the user perform the tracking of a cow using the mouse. Returns 
% variable position that contains [frame BB r]
% where BB = bounding box for frame f, and r = corr(old_frame(BB),new_frame(BB)).

% =========================================================================

% set to 1 when user wants to stop traj tracking - global is a bad practice
% I know, but that is the only way I can see of stopping the loop in
% track_cow_dt.
global stop_tracking;

% color palette to display all 30 cows with different colors
palette = [];
nbc = 4;
dc = linspace(0,1,nbc);
m = 0;
for ii=1:nbc
    for jj=1:nbc
        for kk=1:nbc
            m = m + 1;
            palette(m,:) = [dc(ii) dc(jj) dc(kk)];
        end
    end
end
tmp = sum(palette,2);
[u,v] = sort(tmp,'descend');
palette = palette(v,:);

% border around the cow when displaying the zoom
border = 100;

% will contain the frame and box  
position = [];

% video dimensions
Nframes = video.NumFrames;
Nlines = video.Height;
Ncolumns = video.Width;
fps = video.FrameRate;
dt = 1/fps;

% number of cows already tracked
cow = length(cow_gs);

for f=start:delta_frame:Nframes

    % if = read new frame only if necessary
    if f==start
        % 0 read first frame -> oframe
        oframe = read(video,f);

        % 1) display oframe on the left, let user zoom in and select next
        % cow of interest
        subplot(1,2,1)
        cla
        axis([1 Ncolumns 1 Nlines])
        image(oframe)
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        xlabel(['Frame ' num2str(f)])

        hold on
        % 2) draw previously tracked cows (so we do not track same cow twice)
        for c=1:cow
            frs = cow_gs(c).all_frames;
            bbs = cow_gs(c).BBf;
            pos = find(frs==f);
            if not(isempty(pos))
                draw_box_LTWH(bbs(pos,:),palette(c,:),1)
            end
        end

        % 3) let user detect the cow -> oBB
        tmp = drawrectangle('Color',[1 0 0]);
        oBB = tmp.Position;
        position = [position; f oBB 0];

        % 4) crop image -> ocrop (will be used to decide if cow moved or
        % not)
        L = max([1 round(oBB(1))]);
        T = max([1 round(oBB(2))]);
        R = min([Ncolumns round(oBB(1)+oBB(3))]);
        B = min([Nlines round(oBB(2)+oBB(4))]);
        ocrop = mean(oframe(T:B,L:R,:),3);

    else
        % read new frame

        %  BB dimensions for previous frame
        L = max([1 round(oBB(1))]);
        T = max([1 round(oBB(2))]);
        R = min([Ncolumns round(oBB(1)+oBB(3))]);
        B = min([Nlines round(oBB(2)+oBB(4))]);

        % crop for previous frame using BB from previous frame
        ocrop = mean(oframe(T:B,L:R,:),3);

        % display next frame (f+delta_frame) -> nframe
        nframe = read(video,f);
        subplot(1,2,2)
        cla
        image(nframe)
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        % draw BB from previous frame
        draw_box_LTWH(oBB,[0 1 0],2)

        % compute cow velocity
        vel = [0 0];
        if height(position)>1
            traj = compute_center_LTWH(position(end-1:end,2),...
                position(end-1:end,3),...
                position(end-1:end,4),...
                position(end-1:end,5));
            vel = (traj(2,:)-traj(1,:))/(round(fps)*dt);
        end

        % refocus view using the current cow velocity
        axis([L-border+vel(1) R+border+vel(1) T-border+vel(2) B+border]+vel(2))

        % 6 crop image with oBB -> ncrop
        ncrop = mean(nframe(T:B,L:R,:),3);

        % 7 compute r = corr(ocrop,ncrop)
        r = corr(ocrop(:),ncrop(:));

        xlabel(['Frame ' num2str(f)])

        hold on
        % draw previously tracked cows
        for c=1:cow
            frs = cow_gs(c).all_frames;
            bbs = cow_gs(c).BBf;
            pos = find(frs==f);
            if not(isempty(pos))
                draw_box_LTWH(bbs(pos,:),palette(c,:),1)
            end
        end

        % 8 if r>=0.9, use oBB for frame
        % else let user detect the cow -> oBB
        if r>=0.9
            % use same BB
            nBB = oBB;
            position = [position; f oBB r];
        else
            %tmp = drawrectangle('Color',[1 0 0]);
            % pause execution until user has set up the BB, and presses
            % Return to move ahead to the next frame.
            % (tried shifted_BB but it does not help).
            tmp = drawrectangle('Position',oBB,'Color',[1 0 0]);

            % stop loop if user presses "Done" button 
            if stop_tracking
                break;
            end
            pause

            % if the current BB is fine, just press Enter
            if isequal(tmp.Position,oBB)
                % use previous BB
                nBB = oBB;
                r = NaN;
            else
                % use newly drawn BB
                nBB = tmp.Position;
            end

            % User can keep current BB by just pressing Enter, or change it
            % and then press Enter. In any case, new BB is just the current
            % frame in tmp:
            nBB = tmp.Position;
            % add it to position
            position = [position; f nBB r];
        end

        % 9 oframe = nframe, ocrop = ncrop
        oframe = nframe;
        ocrop = ncrop;
        oBB = nBB;

        % go back to if
    end

    drawnow

end

r = position;

end