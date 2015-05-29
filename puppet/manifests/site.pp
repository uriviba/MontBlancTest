class test {
	build_source::install{ "fftw":
	        url     => "http://www.fftw.org/fftw-3.3.4.tar.gz",
	}
	include extrae
	include mpich
	include openmpi
	include papi
	include hdf5
}
node 'xubuntu-1404' {
	include test
}
node 'laptop' {
	include test
}
node default {
	include test
	include boost
	include lapack
}
