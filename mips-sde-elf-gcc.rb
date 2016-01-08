require 'formula'

class MipsSdeElfGcc < Formula

    homepage 'http://www.gnu.org/software/gcc/gcc.html'
    url "http://ftpmirror.gnu.org/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2"
    mirror "https://ftp.gnu.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2"
    sha256 'b84f5592e9218b73dbae612b5253035a7b34a9a1f7688d2e1bfaaf7267d5c4db'

    depends_on 'gmp'
    depends_on 'libmpc'
    depends_on 'mpfr'

    depends_on 'cloog' => :optional
    depends_on 'isl' => :optional

    depends_on 'gnu-sed'
    depends_on 'mips-sde-elf-binutils'

    option 'disable-cxx', 'Don\'t build the g++ compiler'

    patch :DATA

    def install
        languages = %w[c]
        languages << 'c++' unless build.include? 'disable-cxx'

        args = [
            "--target=mips-sde-elf",
            "--prefix=#{prefix}",

            "--enable-languages=#{languages.join(',')}",

            "--disable-nls",
            "--disable-shared",
            "--disable-threads",
            "--disable-libssp",
            "--disable-libstdcxx-pch",
            "--disable-libgomp",

            "--with-gnu-as",
            "--with-as=#{Formula["mips-sde-elf-binutils"].opt_bin/'mips-sde-elf-as'}",
            "--with-gnu-ld",
            "--with-ld=#{Formula["mips-sde-elf-binutils"].opt_bin/'mips-sde-elf-ld'}",
            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}",
            "--with-system-zlib",
            "--with-newlib"
        ]
        args << "--with-cloog=#{Formula["cloog"].opt_prefix}" if build.with? "cloog"
        args << "--with-isl=#{Formula["isl"].opt_prefix}" if build.with? "isl"

        mkdir 'build' do
            system "../configure", *args
            system "make", "all-gcc"
            system "make", "all-target-libgcc"

            ENV.deparallelize
            system "make", "install-gcc"
            system "make", "install-target-libgcc"
        end

        # info and man7 files conflict with native gcc
        info.rmtree
        man7.rmtree
    end
end

__END__
diff -Naur a/libgcc/config/t-hardfp b/libgcc/config/t-hardfp
--- a/libgcc/config/t-hardfp
+++ b/libgcc/config/t-hardfp
@@ -73,7 +73,7 @@
 #   TYPE: the last floating-point mode (e.g. sf)
 hardfp_defines_for = \
   $(shell echo $1 | \
-    sed 's/\(.*\)\($(hardfp_mode_regexp)\)\($(hardfp_suffix_regexp)\|\)$$/-DFUNC=__& -DOP_\1\3 -DTYPE=\2/')
+    gsed 's/\(.*\)\($(hardfp_mode_regexp)\)\($(hardfp_suffix_regexp)\|$$\)/-DFUNC=__& -DOP_\1\3 -DTYPE=\2/')
 
 hardfp-o = $(patsubst %,%$(objext),$(hardfp_func_list))
 $(hardfp-o): %$(objext): $(srcdir)/config/hardfp.c
diff -Naur a/gcc/config/mips/t-sde b/gcc/config/mips/t-sde
--- a/gcc/config/mips/t-sde
+++ b/gcc/config/mips/t-sde
@@ -33,5 +33,5 @@
 MULTILIB_EXCLUSIONS += !mips32/!mips32r2/mmicromips
 else
 MULTILIB_EXCLUSIONS += mips64/mips16 mips64r2/mips16
-MULTILIB_EXCLUSIONS += mips64/mmicromips mips64r2/mmicromips
+MULTILIB_EXCLUSIONS += !mips32/!mips32r2/mmicromips
 endif
