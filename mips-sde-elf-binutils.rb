require 'formula'

class MipsSdeElfBinutils < Formula

    homepage 'http://www.gnu.org/software/binutils/binutils.html'
    url 'http://ftpmirror.gnu.org/binutils/binutils-2.25.tar.gz'
    mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz'
    sha1 'f10c64e92d9c72ee428df3feaf349c4ecb2493bd'

    def install
        args = [
            "--target=mips-sde-elf",
            "--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--enable-interwork",
            "--enable-multilib",
            "--disable-debug",
            "--disable-dependency-tracking",
            "--disable-werror",
            "--disable-nls"
        ]

        mkdir 'build' do
            system "../configure", *args

            system "make"
            system "make", "install"
        end

        info.rmtree
    end
end
