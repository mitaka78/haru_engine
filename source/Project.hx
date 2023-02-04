package;

import sys.FileSystem;
import sys.io.File;

using StringTools;

class Project
{
	public static function make(dir:String)
	{
		FileSystem.createDirectory('projects/$dir');
		FileSystem.createDirectory('projects/$dir/export');
		FileSystem.createDirectory('projects/$dir/export/images');
		FileSystem.createDirectory('projects/$dir/export/data');
	}

	public function timestamp(dir:String)
	{
		File.saveContent('projects/$dir/timestamp', Std.string(Sys.time()));
	}

	public static function pack(dir:String)
	{
		FileSystem.createDirectory('projects/$dir/export');
		for (f in FileSystem.readDirectory('projects/$dir'))
		{
			if (f.endsWith('.png') || f.endsWith('.jpg') || f.endsWith('.jpeg'))
			{
				File.copy(f, 'projects/$dir/export/${f}');
			}
			else if (f.endsWith('.hso')) // Haru Sprite Objects
			{
				File.copy(f, 'projects/$dir/export' + f);
			}
		}
	}
}
