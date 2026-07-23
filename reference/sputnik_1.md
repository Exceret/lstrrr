# Sputnik 1 nested example data

A nested list containing structured information about Sputnik 1, the
first artificial Earth satellite.

## Usage

``` r
sputnik_1
```

## Format

A nested list.

## Source

NASA History, Sputnik and the Dawn of the Space Age:
<https://www.nasa.gov/wp-content/uploads/static/history/sputnik.html>

NASA History, Korolev, Sputnik, and the International Geophysical Year:
<https://www.nasa.gov/history/sputnik/siddiqi.html>

National Museum of the United States Air Force, Sputnik I:
<https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/197681/sputnik-i/>

U.S. Department of State, Sputnik, 1957:
<https://history.state.gov/milestones/1953-1960/sputnik>

Wikipedia, Sputnik 1: <https://en.wikipedia.org/wiki/Sputnik_1>

## Details

The object includes historical metadata, spacecraft specifications,
launch information, orbital parameters, radio system details, mission
objectives, chronology, Cold War context, related spacecraft, source
notes, and additional branches designed for testing recursive list
traversal.

This dataset is useful for testing functions such as
[`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
[`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
[`list_pmap()`](https://exceret.github.io/lstrrr/reference/list_pmap.md),
and
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md)
because it contains:

- deeply nested lists;

- named and unnamed branches;

- `NULL` leaves;

- empty lists;

- `Date` and `POSIXct` objects;

- numeric and character vectors;

- data frames that should be treated as leaf values.

## Examples

``` r
data(sputnik_1)

names(sputnik_1)
#>  [1] "meta"               "identity"           "launch"            
#>  [4] "spacecraft"         "orbit"              "mission_objectives"
#>  [7] "chronology"         "historical_context" "related_spacecraft"
#> [10] "source_notes"       "test_branches"     

sputnik_1$identity$names$common
#> [1] "Sputnik 1"
sputnik_1$spacecraft$physical$mass_kg
#> [1] 83.6
sputnik_1$orbit$canonical_values$period_min
#> [1] 96.2

# Useful with recursive mapping:
# list_nleaf(sputnik_1)
# list_imap(sputnik_1, \(x, path) paste(path, collapse = "."), .name = "path")
```
