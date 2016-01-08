require 'formula'

class MipsSdeElfGdb < Formula

    homepage 'http://www.gnu.org/software/gdb/'
    url "http://ftp.gnu.org/gnu/gdb/gdb-7.10.1.tar.xz"
    mirror "http://ftpmirror.gnu.org/gnu/gdb/gdb-7.10.1.tar.xz"
    sha256 "25c72f3d41c7c8554d61cacbeacd5f40993276d2ccdec43279ac546e3993d6d5"
    depends_on 'mips-sde-elf-binutils'
    
    depends_on 'cloog' => :optional
    depends_on 'isl' => :optional

    def install
        args = [
            "--target=mips-sde-elf",
            "--prefix=#{prefix}",

            "--disable-nls",
            "--disable-libssp",
            "--disable-install-libbfd",
            "--disable-install-libiberty",

            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}"
        ]
        args << "--with-cloog=#{Formula["cloog"].opt_prefix}" if build.with? "cloog"
        args << "--with-isl=#{Formula["isl"].opt_prefix}" if build.with? "isl"

        mkdir 'build' do
            system "../configure", *args
            system "make"

            ENV.deparallelize
            system "make install"
        end

        # info conflicts with binutils
        info.rmtree
    end
end
