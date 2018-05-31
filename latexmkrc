
# support for the glossaries package:
add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
add_cus_dep('slo', 'sls', 0, 'makeglossaries');
sub makeglossaries {
  # system("makeglossaries \"$_[0]\"");
  my ($base_name, $path) = fileparse( $_[0] );
  pushd $path;
  my $return = system "makeglossaries $base_name";
  popd;
  return $return;
}

# support for the nomencl package:
add_cus_dep('nlo', 'nls', 0, 'makenlo2nls');
sub makenlo2nls {
  system("makeindex -s nomencl.ist -o \"$_[0].nls\" \"$_[0].nlo\"");
}

# from the documentation for V. 2.03 of asymptote:
sub asy {return system("asy \"$_[0]\"");}
add_cus_dep("asy","eps",0,"asy");
add_cus_dep("asy","pdf",0,"asy");
add_cus_dep("asy","tex",0,"asy");

# metapost rule from http://tex.stackexchange.com/questions/37134
add_cus_dep('mp', '1', 0, 'mpost');
sub mpost {
  my $file = $_[0];
  my ($name, $path) = fileparse($file);
  pushd($path);
  my $return = system "mpost $name";
  popd();
  return $return;
}

$latex = 'latex %O -shell-escape %S';
$pdflatex = 'pdflatex %O -shell-escape %S';
#$lualatex = 'lualatex %O --shell-escape --synctex=0 %S';


our %externalflag = ();

$lualatex = 'internal mypdflatex %O --shell-escape --synctex=0 %S %B';

use Cwd;

sub mypdflatex {
  our %externalflag;
  my $n = scalar(@_);
  my @args = @_[0 .. $n - 2];
  my $base = $_[$n - 1];

  system 'lualatex', @args;
  if ($? != 0) {
    return $?
  }
  if ( !defined $externalflag->{$base} ) {
    $externalflag->{$base} = 1;
    my $dir = getcwd();
    print "Dir $dir \n";
    print "$make -j4 -f $base.makefile\n";
    system ("$make -j4 -f $base.makefile");
  }
  return $?;
}

