perl-code-search
================

Simple and kinda dumb Perl code search engine

Synopsis
--------

```
find . -type f -name '*.p[lm]' | create_calldb.pl > calldb.yaml

track_calls.pl --db=calldb.yaml --name=sub_name > output.yaml
track_calls.pl --db=calldb.yaml --name=sub_name --files > output_with_additional_info.yaml
```

