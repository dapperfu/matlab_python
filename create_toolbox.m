function create_toolbox()

here = fileparts(mfilename('fullpath'));

WINPYTHON_URL = getenv('WINPYTHON_URL');
if isempty(WINPYTHON_URL)
    WINPYTHON_URL = 'https://github.com/winpython/winpython/releases/download/1.9.20171031/WinPython-64bit-3.6.3.0Zero.exe';
end
[~, python_version, ext] = fileparts(WINPYTHON_URL);

winpython_dir = fullfile(here, python_version);
winpython_exe = ([python_version, ext]);
winpython_toolbox = fullfile(winpython_dir, [python_version, '.mltbx']);
winpython_project = fullfile(winpython_dir, [python_version, '.prj']);

if (exist(winpython_exe, 'file')==0)
    fprintf('Downloading %s ...', winpython_exe);
    websave(winpython_exe, WINPYTHON_URL);
    fprintf('... Done.\n');
    feval(mfilename);
    return;
end

if (exist(winpython_dir, 'dir')==0)
    fprintf('Extracting %s ...', winpython_exe);
    cmd = sprintf('%s  /S /D="%s"', winpython_exe, winpython_dir);
    [status, message] = dos(cmd);
    fprintf('... Done.\n');
    feval(mfilename);
    return;
end

if (exist(winpython_toolbox, 'file')==0)
    if exist(winpython_project, 'file')
        delete(winpython_project);
    end
    
    fprintf('Creating MATLAB project ...'); 
    service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
    
    project_key = service.createNewProject(winpython_dir);
    
    service.saveAs(project_key, [winpython_dir '.prj']);
    
    service.setToolboxRoot(project_key, winpython_dir);
    
    service.setAuthorName(project_key, getenv('USERNAME'));
    service.setDescription(project_key, 'A description');
    
    [~, package_folder] = fileparts(winpython_dir);
    service.saveAs(project_key, [winpython_dir '.prj']);
    
    fprintf('... Done\n');
    
    fprintf('Packaging MATLAB project ...'); 
    service.packageProject(project_key);
    fprintf('... Done\n');
    return;
else
    error('WinPython toolbox exists: %s', winpython_project);
end
