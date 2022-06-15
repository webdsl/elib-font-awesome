# ELib FontAwesome

Font Awesome library for WebDSL.

Current Font Awesome version: 6.1.1

## Usage
Import the `lib.app` in your application:

```webdsl
imports elib/elib-fontawesome/lib
```

To refer to an icons such as the `solid` style `circle-xmark` of FontAwesome, use `fasCircleXmark`, where the `fas` stands for FontAwesome Solid. Similarly, to refer to the `regular` style, use `farCicleXmark`, where again `far` stands for FontAwesome Regular.


## Update Script
To regenerate the `icons.app`, run the `update.sh` script. To change the FontAwesome version, change the `FA_VERSION` variable at the top of the script. To run `update.sh`, you need to have installed:

- `python-yq` (`brew install python-yq`)
- `wget` (`brew install wget`)
- `unzip`


### JQ Magic
The `update.sh` script uses `yq` to parse the FontAwesome YAML file and pass it onto the [`jq` tool](https://stedolan.github.io/jq/). This tool is then used to extract the information from the YAML file and build the syntax for WebDSL.

The query starts at `to_entries`, which takes the entries from the input file's root array. It passed that into a big `map()` function, which does the following:
- `.` takes the current node;
- `.key as $key` takes the key of the current map node and stores it in `$key`;
- `((.key / "-") | map((.[:1] | ascii_upcase) + .[1:]) | join("")) as $name` takes the key of the current map node, splits it on the dashes, makes every part start with an uppercase letter, and joins them back together into a string. This changes a key such as `toilet-paper-slash` into `ToiletPaperSlash`, which is stored in `$name`;
- `.value.styles[] | . as $style |` takes each style defined in the node and continues with each combination of key and style. It stores the style in `$style`. If a name defined two styles, this will get both combinations of `$key` and `$style`;
- `.[:1] as $letter` takes the first letter of the style and stores it in `$letter`;
- `"  fa\($letter)\($name) i[class=\"fa-\($style) fa-\($key)\"]"` constructs the WebDSL syntax that corresponds to HTML such as `<i class="fa-solid fa-biohazard"></i>`, as specified in the FontAwesome documentation;

Finally, we split the array of strings into separate JQ responses using `.[]`, each of which is written without quotes (due to invoking `jq -r`) separated by newlines to the standard out, which is redirected to `icons.app`.
