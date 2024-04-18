# Shim for systems without realpath(1)

realpath() {
    echo $(perl -MFile::Spec -lE "print File::Spec->rel2abs('$1')")
}
