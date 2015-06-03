define build_source::archive(
	$url,
	$version = '',
	$dest = '', 
	$configureAdd='',
	$creates='configure',
) {
	require stdlib
	ensure_resource('file','/usr/local/bin/extract.pl',{'ensure' => 'file','owner'  => 'root','group'  => 'root', 'mode'   => '755','source' => "puppet:///modules/build_source/extract.pl"})
	$filename = inline_template('<%= File.basename(@url) %>')
	Exec {
		user    => 'root',
		timeout => $timeout,
		path    => '/usr/bin:/bin',
	}
	if ($dest == '') {
		if ($version == '') {
			$archiveDest="/usr/src/$name"
		}
		else {
			$archiveDest="/usr/src/${name}/${version}"
		}	
	}
	else {
		$archiveDest=$dest
	}
	if ($configureAdd==''){
		$_creates = $archiveDest 
	} else {
		$_creates = "$archiveDest/$configureAdd"
	}
	
	$pathComplet = getPaths($archiveDest)
	ensure_resource('file',$pathComplet,{'ensure' => 'directory','owner' => 'root', 'group' => 'root'})
	
	if ($url =~ /^http(s)?:\/\// or $url =~ /^ftp:\/\//) {
		exec { "Download $title":
			command => "wget $url -O $filename",
			cwd     => "/tmp",
			creates => "/tmp/$filename",
			before  => Exec["Extract $title"]
		}
	}
	else{
		file {"/tmp/$filename":
			ensure => file,
			source => "puppet:///modules/$url",
			owner  => 'root',
			group  => 'root',
			before => Exec["Extract $title"]
		}
	}
	exec { "Extract $title":
       		command => "/usr/local/bin/extract.pl /tmp/$filename",
		cwd     => "$archiveDest",
		creates => "$_creates/$creates",
		require => [File['/usr/local/bin/extract.pl'],File[$pathComplet]]
	}
}
