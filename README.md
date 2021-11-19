# BeefFNT

## Introduction

BeefFNT is a Beef library for reading and writing [AngelCode bitmap fonts (.fnt)](http://www.angelcode.com/products/bmfont/) in binary, XML, and text. This library is a port of [SharpFNT](https://github.com/AuroraBertaOldham/SharpFNT), with adjustments to make it work better in Beef.

## Dependencies

This library depends on [Xml-Beef](https://github.com/thibmo/Xml-Beef) for reading/writing Xml.

## Example

The following loads a bitmap font from a file, outputs the name of the font, changes the font name, and then saves it as a new binary bitmap font.

```cs
using BeefFNT;

if (BitmapFont.FromFile("ExampleFont.fnt") case .Ok(let bitmapFont))
{
  defer delete bitmapFont;

  Console.WriteLine(bitmapFont.Info.Face);

  bitmapFont.Info.Face = "New Name";

  bitmapFont.Save("ExampleFont2.fnt", FormatHint.Binary);
}
```

## Documentation
See the [documentation for BMFont](http://www.angelcode.com/products/bmfont/documentation.html) for information on rendering text and the properties of the file format.

## License
Licensed under [MIT](LICENSE).
