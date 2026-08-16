This is tricky.

Basicaly L026 works to make sure qualified columns only use tables in the from clause. This doesn’t really work for `STRUCT`s as impossible to know if it’s a qualified column or a `STRUCT`, so is off by default for languages that support them - like BigQuery.

L027 works to make sure columns are qualified for multi-table joins (i.e. have at least one dot). But it doesn’t check the qualifiers are valid - that’s L026’s job, which as I say is off by default for BigQuery.