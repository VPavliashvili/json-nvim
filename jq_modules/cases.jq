# taken from https://github.com/reegnz
# https://github.com/reegnz/dotfiles/blob/master/jq/.jq

def head($count):
  .[0:$count]|select(length > 0) |
  if type == "array" then .[] else . end;


def tail($count):
  .[$count:];


def head:
  head(1);


def tail:
  tail(1);


def capitalize:
  (head | ascii_upcase) + tail;


def from_kebab:
  split("-");


def to_kebab:
  join("-");


def from_snake:
  split("_");


def to_snake:
  join("_");


def from_pascal:
  [splits("(?=[A-Z])")] | map(select(. != "")) | map(ascii_downcase);


def to_pascal:
  map(capitalize) | join("");


def from_camel:
  from_pascal;


def to_camel:
  [ head ] + (tail | map(capitalize)) | join("");


def from_constant:
  from_snake | map(ascii_downcase);


def to_constant:
  map(ascii_upcase) | join("_");


def from_dot:
  split(".");


def to_dot:
  join(".");


def from_header:
  split("-") | map(ascii_downcase);


def to_header:
  map(capitalize) | join("-");

def to_manycase_regex:
  join("[ -_]*");


def map_keys(mapper):
  walk(
    if type == "object" then
      with_entries(.key |= mapper)
    else .
    end
  );
