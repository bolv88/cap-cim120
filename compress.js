// you need to install yui compress: npm i yuicompressor
//
var compressor = require('yuicompressor');
var fs = require('fs');
var path = require('path');
var arguments = process.argv.splice(2);

if (arguments.length != 2) {
  error_exit("usage: node compress.js inputfile outfold");
}

function compress_static_file(frompath, outfold) {
  var extname = path.extname(frompath);
  extname = extname.replace(".", "")
  if (["js", "css"].indexOf(extname) < 0) {
    error_exit("only support js/css compress." + extname);

  }
  compressor.compress(frompath, {
    //Compressor Options:
    charset: 'utf8',
    type: extname,
    nomunge: true,
    'line-break': 5000
  }, function(err, data, extra) {
    if (err) {
      error_exit(err);
    }
    //err   If compressor encounters an error, it's stderr will be here
    //data  The compressed string, you write it out where you want it
    //extra The stderr (warnings are printed here in case you want to echo them
    //console.log(err)
    //console.log(data)
    //console.log(extra)
    //console.log(frompath)
    //
    var filename = path.basename(frompath)

    var outfile = outfold+"/"+filename
    var w = fs.createWriteStream(outfile+".uncompressed")

    w.on("error", function(err){
      console.log("write err "+err)
    });

    w.on("close", function(err){
      console.log("copyed file to uncompress")
      fs.writeFile(outfile, data, function(err){
        if (err) {
          //exit and roolback
          error_exit(err);
        }
        console.log("writed compressed file!");
      });
    })

    fs.createReadStream(frompath).pipe(w);
  });
}
function error_exit(msg) {
  if (msg) {
    console.log(msg);
  }
  //process.emit("exit"); 
  console.log("exit 1")
  process.exit(1);
}
//var file = "./test.js"
compress_static_file(arguments[0], arguments[1])
//
//console.log("basename: " + path.basename(file))
//console.log("dirname: " + path.dirname(file))
