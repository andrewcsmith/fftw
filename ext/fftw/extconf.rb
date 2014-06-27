require 'mkmf'

# FFTW for i866 or x86-64 Computers
#def install
#  system 'cd ../../fft3; ./configure  --enable-float  --enable-threads  --enable-sse'
#end
LIBDIR = RbConfig::CONFIG['libdir']
INCLUDEDIR = RbConfig::CONFIG['includedir']

HEADER_DIRS = ['/opt/local/include',
               '/usr/local/include',
                INCLUDEDIR,
               '/usr/include',
               '/usr/include/atlasl']

dir_config('../../include','/usr/include','/usr/include/atlas')
if ( ! have_header("fftw3.h") && have_library("fftw3") ) then
   print <<-EOS
   ** configure error **

   Header fftw3.h or the compiled fftw3 library is not found.
   If you have the library installed under /fftw3-dir (that is, fftw3.h is
   in /fftw3-dir/include and the library in /fftw3-dir/lib/),
   try the following:
   % ruby extconf.rb --with-fftw3-dir=/fftw3-dir

   Alternatively, you can specify the two directory separately
   with --include-dir and --fftw3-dir 
  EOS
  exit(-1)
end

if have_library("fftw3f")
 $CFLAGS += ' -DFFTW3_HAS_SINGLE_SUPPORT -Wall -I/usr/include'
end

def find_newer_gplusplus #:nodoc:
  print "checking for apparent GNU g++ binary with C++0x/C++11 support... "
  [9,8,7,6,5,4,3].each do |minor|
    ver = "4.#{minor}"
    gpp = "g++-#{ver}"
    result = `which #{gpp}`
    next if result.empty?
    CONFIG['CXX'] = gpp
    puts ver
    return CONFIG['CXX']
  end
  false
end
create_makefile("fftw")
