import std.algorithm;
import std.array;
import std.random;
import std.range;
import std.stdio;

// The Boost License applies to the present file, as described in file ./LICENSE

// usage:
// rdmd <this_filename>
// works with at least LDC 1.30.0 - DMD v2.100.1

void main()
// https://en.wikipedia.org/wiki/Secretary_problem
{
  writeln("youpi");

  immutable LENGTH = 100;
  immutable N_ITER = 100000;

  auto acc_score = new double[ LENGTH ];
  acc_score[] = 0.0;

  writefln( "N_ITER: %d", N_ITER );
  
  foreach (_; 0..N_ITER)
    {
      if (999 == _ % 1000) { write( _, " / ", N_ITER, '\r' ); stdout.flush; }
      
      auto arr = iota( LENGTH ).array.randomShuffle;
      foreach (i; 0..LENGTH-1)
        {
          immutable max_before  = arr[ 0..(i+1) ].reduce!max;
          immutable max_overall = arr.reduce!max;

          immutable selected = (){

            auto x2 = arr[ i+1 ];
            foreach (x; arr[ i+1..LENGTH ])
            {
              x2 = x;
              if (x2 > max_before)
                break;
            }
            return x2;
          }();
          
          if (selected == max_overall)
            acc_score[ i ] += 1.0;
          
        }
    }
  writeln;
  
  acc_score[] /= (cast( double )( N_ITER ));

  writefln( "[%( %.4f%) ]", acc_score );

  immutable maxind = acc_score.maxIndex;
  writefln( "maxIndex: %d / %d  (%.2f%%)", maxind, LENGTH, 100.0 * (cast(double)( maxind )) / (cast(double)( LENGTH )) );
}
