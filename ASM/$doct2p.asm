This library contains the source for the assembler routines used by the
text-to-pdf (txt2pdf) application.  Each member contains the source
wrapped with the necessary JCL to assemble and link the module.  The
only change required is to insert your own job statement and change the
name of the target load library.

With the exception of T2PCOMP, each module can be placed into LPA if
desired or into a linklisted library.

Members:

  T2PARC4
  T2PCOMP
  T2PINIT
  T2PMD5
  T2PTERM
