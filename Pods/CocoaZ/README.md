# CocoaZ

CocoaZ is an Objective-C based compression library. It provides an easy to use and flexible interface on top of the venerable [zlib][]. It is well suited for both file and stream based compression/decompression.

## Installation

Install the library via [Cocoa Pods][] by adding the following entry in your `Podfile`:

    pod 'CocoaZ', '~> 1.2'

Alternatively, import all the source files inside the `CocoaZ/` subdirectory into your project. If you do this, don't forget to link your binary with `libz` (linker flag: `-lz`).

## Usage

### Compression

To begin compression, create an instance of `TDTZCompressor`.

    // level must be between 0 and 9
    // 0 = no compression, 1 = fastest compression, 9 = best compression
    TDTZCompressor *compressor = [[TDTZCompressor alloc] initWithCompressionFormat:TDTCompressionFormatGzip level:6];

Start sending `NSData` for compression using `-compressData:`. Compressed data is returned back, but all input data may not be compressed immediately. `-compressData:` can be called as many times as desired.

    // Get input data from the source, say a file or a stream
    // Send output data to the destination
    NSData *output = [compressor compressData:input];

To force compression of everything sent till now, call `-flushData:`. The input to `-flushData:` can be either an `NSData` (which will be included in the compressed data returned back) or `nil`.

    NSData *output = [compressor flushData:input];

Once all input data has been sent for compression, call `-finishData:`. This method also flushes any remaining input. As with `-flushData:`, the input can be either an `NSData` or `nil`.

    NSData *lastOutput = [compressor finishData:input];

After the call to `-finishData:` returns, compression is finished. None of the compression methods should be called anymore.

### Decompression

Decompression works very similar to compression. First, you create an instance of `TDTZDecompressor`.

    TDTZDecompressor *decompressor = [[TDTZDecompressor alloc] initWithCompressionFormat:TDTCompressionFormatGzip];

Decompress input data using `-decompressData:`.

    NSData *output = [decompressor decompressData:input];

Flush decompressed data using `-flushData:`.

    NSData *output = [decompressor flushData:input];

Once all input has been sent for decompression, call `-finishData:`.

    NSData *lastOutput = [decompressor finishData:input];

### Convenience methods

`-compressFile:error:` allows you to easily compress a file into memory. If you plan to use this method, note that it should only be used once and it should not be mixed with calls to the other compression methods.

    TDTZCompressor *compressor = [[TDTZCompressor alloc] initWithCompressionFormat:TDTCompressionFormatGzip level:6];
    NSError *error;
    NSData *output = [compressor compressFile:@"/path/to/file" error:&error];
    if (output == nil) {
      NSLog(@"Error compressing file: %@", error);
    }

Similarly, `-decompressFile:error:` allows you to decompress a file into memory.

    TDTZDecompressor *decompressor = [[TDTZDecompressor alloc] initWithCompressionFormat:TDTCompressionFormatGzip level:6];
    NSError *error;
    NSData *output = [decompressor decompressFile:@"/path/to/file" error:&error];
    if (output == nil) {
      NSLog(@"Error decompressing file: %@", error);
    }

## Documentation and Resources

Go through [TDTZCompressor.h](CocoaZ/TDTZCompressor.h) and [TDTZDecompressor.h](CocoaZ/TDTZDecompressor.h) for more details on the API.

zlib, and hence this library, allows compression/decompression in two formats. _zlib_ and _gzip_. _zlib_, described in [RFC 1950][], is a wrapper over a _deflate_ stream ([RFC 1951][]). _gzip_ ([RFC 1952][]) is different from _zlib_, but it too wraps over a _deflate_ stream. To know more about _deflate_ and the two compression formats, see the RFCs.

To know more about the zlib library, see its [manual][zlib manual].

## Issues and Feedback

To report any issues with the library, create an issue on [Github](https://github.com/talk-to/CocoaZ/issues).

For any other feedback or suggestion, contact the maintainers (listed below).

## Making Releases (For Maintainers)

See `rake release:prepare` and `rake release:push`.

## Maintainers

* [Chaitanya Gupta](https://github.com/chaitanyagupta) ([@chaitanya_gupta](https://twitter.com/chaitanya_gupta))
* [Udit Aggarwal](https://github.com/uditiiita) ([@MastChamp](https://twitter.com/MastChamp))
* [Abhay Singh](https://github.com/AbhaySingh) ([@AbhaySingh35](https://twitter.com/AbhaySingh35))

[zlib]: http://zlib.net/
[zlib manual]: http://zlib.net/manual.html
[RFC 1950]: http://tools.ietf.org/html/rfc1950
[RFC 1951]: http://tools.ietf.org/html/rfc1951
[RFC 1952]: http://tools.ietf.org/html/rfc1952
[Cocoa Pods]: http://cocoapods.org/
