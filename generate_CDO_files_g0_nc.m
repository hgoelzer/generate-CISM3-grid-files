function [ successfully_completed ] = generate_CDO_files2(agrid, proj_info, output_data_type, flag_nc, flag_txt, flag_xy)

%% Make X,Y cartesian coordinates
dx=agrid.dx;
dy=agrid.dy;
nx_centers=agrid.nx_centers;
ny_centers=agrid.ny_centers;
nsize=agrid.nx_centers*agrid.ny_centers;
%% Create gridded x and y
[ycenters,xcenters]=meshgrid((0:ny_centers-1).*dy , (0:nx_centers-1).*dx);


%% Write 2d xy netcdf file
if(flag_xy)
        disp(['Generating ' agrid.xyOutputFileName ])

if exist(agrid.xyOutputFileName, 'file') ~= 0;
    delete(agrid.xyOutputFileName)
end

%% write 2D and 1d x,y
wnc(xcenters-proj_info.falseeasting,agrid.xyOutputFileName,'x02','m','grid center x-coordinate',{'x0','y0'},0,'NETCDF4')
wnc(ycenters-proj_info.falsenorthing,agrid.xyOutputFileName,'y02','m','grid center y-coordinate',{'x0','y0'},0,'NETCDF4')

wnc(squeeze(xcenters(:,1))-proj_info.falseeasting,agrid.xyOutputFileName,'x0','m','grid center x-coordinate','x0',0,'NETCDF4')
wnc(squeeze(ycenters(1,:))-proj_info.falsenorthing,agrid.xyOutputFileName,'y0','m','grid center y-coordinate','y0',0,'NETCDF4')

end

if(flag_nc || flag_txt)

%% Create lat,lon coordinates
[LI_grid_center_lat,LI_grid_center_lon]=polarstereo_inv(...
    xcenters(:)-proj_info.falseeasting+round(dx/2),...
    ycenters(:)-proj_info.falsenorthing+round(dy/2),...
    proj_info.earthradius,proj_info.eccentricity,...
    proj_info.standard_parallel,...
    proj_info.longitude_rot);
                                    
LI_grid_center_lat=reshape(LI_grid_center_lat,size(ycenters));
LI_grid_center_lon=reshape(LI_grid_center_lon,size(xcenters));

[ycorners,xcorners]=meshgrid((0:ny_centers).*dy-dy./2 , (0:nx_centers).*dx-dx./2);
[LI_grid_corner_lat,LI_grid_corner_lon]=polarstereo_inv(...
    xcorners(:)-proj_info.falseeasting+round(dx/2),...
    ycorners(:)-proj_info.falsenorthing+round(dy/2),...
    proj_info.earthradius,proj_info.eccentricity,...
    proj_info.standard_parallel,...
    proj_info.longitude_rot);

LI_grid_corner_lat=reshape(LI_grid_corner_lat,size(ycorners));
LI_grid_corner_lon=reshape(LI_grid_corner_lon,size(xcorners));


%% Generate 3d corner coordinates

LI_grid_center_lat_CDO_format=LI_grid_center_lat;
LI_grid_center_lon_CDO_format=LI_grid_center_lon;

LI_grid_corner_lat_CDO_format=zeros([4,size(LI_grid_center_lat_CDO_format)]);

NEcorner_lat=LI_grid_corner_lat(2:end,1:end-1);     LI_grid_corner_lat_CDO_format(1,:,:)=NEcorner_lat;
SEcorner_lat=LI_grid_corner_lat(2:end,2:end);       LI_grid_corner_lat_CDO_format(2,:,:)=SEcorner_lat;
SWcorner_lat=LI_grid_corner_lat(1:end-1,2:end);     LI_grid_corner_lat_CDO_format(3,:,:)=SWcorner_lat;
NWcorner_lat=LI_grid_corner_lat(1:end-1,1:end-1);   LI_grid_corner_lat_CDO_format(4,:,:)=NWcorner_lat;

LI_grid_corner_lon_CDO_format=zeros([4,size(LI_grid_center_lon_CDO_format)]);

NEcorner_lon=LI_grid_corner_lon(2:end,1:end-1);     LI_grid_corner_lon_CDO_format(1,:,:)=NEcorner_lon;
SEcorner_lon=LI_grid_corner_lon(2:end,2:end);       LI_grid_corner_lon_CDO_format(2,:,:)=SEcorner_lon;
SWcorner_lon=LI_grid_corner_lon(1:end-1,2:end);     LI_grid_corner_lon_CDO_format(3,:,:)=SWcorner_lon;
NWcorner_lon=LI_grid_corner_lon(1:end-1,1:end-1);   LI_grid_corner_lon_CDO_format(4,:,:)=NWcorner_lon;

%LI_grid_center_lon_CDO_format=wrapTo360(LI_grid_center_lon_CDO_format);
%LI_grid_corner_lon_CDO_format=wrapTo360(LI_grid_corner_lon_CDO_format);

if strcmp(output_data_type,'radians')
    LI_grid_center_lat_CDO_format=deg2rad(LI_grid_center_lat_CDO_format);
    LI_grid_center_lon_CDO_format=deg2rad(LI_grid_center_lon_CDO_format);
    LI_grid_corner_lat_CDO_format=deg2rad(LI_grid_corner_lat_CDO_format);
    LI_grid_corner_lon_CDO_format=deg2rad(LI_grid_corner_lon_CDO_format);
end

LI_grid_dims_CDO_format=int32(size(LI_grid_center_lat_CDO_format));
LI_grid_imask_CDO_format=zeros(LI_grid_dims_CDO_format,'int32');
LI_grid_imask_CDO_format(:,:)=1;

end

%% Write CDO grid netcdf file
if(flag_nc)
        disp(['Generating ' agrid.LatLonOutputFileName ])

if exist(agrid.LatLonOutputFileName, 'file') ~= 0;
    delete(agrid.LatLonOutputFileName)
end

% grid centers
wnc(LI_grid_center_lat,agrid.LatLonOutputFileName,'lat','degrees_north','grid center latitude',{'x','y'},0,'NETCDF4')
ncwriteatt(agrid.LatLonOutputFileName,'lat','standard_name','latitude')
ncwriteatt(agrid.LatLonOutputFileName,'lat','bounds','lat_bnds')

wnc(LI_grid_center_lon,agrid.LatLonOutputFileName,'lon','degrees_east','grid center longitude',{'x','y'},0,'NETCDF4')
ncwriteatt(agrid.LatLonOutputFileName,'lon','standard_name','longitude')
ncwriteatt(agrid.LatLonOutputFileName,'lon','bounds','lon_bnds')

% bounds
wnc(LI_grid_corner_lat_CDO_format,agrid.LatLonOutputFileName,'lat_bnds','degrees_north','grid corner latitude',{'nv4','x','y'},0,'NETCDF4')
wnc(LI_grid_corner_lon_CDO_format,agrid.LatLonOutputFileName,'lon_bnds','degrees_east','grid corner longitude',{'nv4','x','y'},0,'NETCDF4')

% dummy needed for mapping
wnc(int8(LI_grid_center_lon*0+1),agrid.LatLonOutputFileName,'dummy','1','dummy variable',{'x','y'},0,'NETCDF4')
% add lat,lon mapping
ncwriteatt(agrid.LatLonOutputFileName,'dummy','coordinates','lon lat')

end


%% Write CDO grid text file
if(flag_txt)
    disp(['Generating ' agrid.CDOOutputFileName ])
if exist(agrid.CDOOutputFileName, 'file');
    delete(agrid.CDOOutputFileName)
end

fileID = fopen(agrid.CDOOutputFileName,'w');
fprintf(fileID,'%s\n','gridtype  = curvilinear');
fprintf(fileID,'%s\n',['gridsize  =' , num2str(nsize)]);
fprintf(fileID,'%s\n',['xsize  = ' , num2str(nx_centers)]);
fprintf(fileID,'%s\n',['ysize  = ' , num2str(ny_centers)]);

fprintf(fileID,'%s\n','xvals  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_center_lon_CDO_format);
fprintf(fileID,'%s\n',' ');

fprintf(fileID,'%s\n','xbounds  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_corner_lon_CDO_format);

fprintf(fileID,'%s\n','yvals  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_center_lat_CDO_format);
fprintf(fileID,'%s\n',' ');

fprintf(fileID,'%s\n','ybounds  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_corner_lat_CDO_format);

fclose(fileID);
end

successfully_completed = 1;

