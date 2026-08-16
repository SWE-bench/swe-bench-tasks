# TODO

## Build and push the missing dev images

49 of the 225 dev tasks name an image that is not on Docker Hub, so
those tasks cannot be run even though the dataset publishes them:

```
swebench images build . -i <instance_id>
swebench images push . -i <instance_id>
```

The dev Dockerfiles are generated from the repo and version specs, not from a
pinned environment.yml like the test ones, so check a build before pushing it.

### pvlib (6)

- [ ] pvlib__pvlib-python-1031
- [ ] pvlib__pvlib-python-1157
- [ ] pvlib__pvlib-python-1218
- [ ] pvlib__pvlib-python-1225
- [ ] pvlib__pvlib-python-1719
- [ ] pvlib__pvlib-python-1740

### pydicom (2)

- [ ] pydicom__pydicom-1050
- [ ] pydicom__pydicom-866

### sqlfluff (41)

- [ ] sqlfluff__sqlfluff-1577
- [ ] sqlfluff__sqlfluff-2326
- [ ] sqlfluff__sqlfluff-2336
- [ ] sqlfluff__sqlfluff-2386
- [ ] sqlfluff__sqlfluff-2509
- [ ] sqlfluff__sqlfluff-2573
- [ ] sqlfluff__sqlfluff-2625
- [ ] sqlfluff__sqlfluff-2641
- [ ] sqlfluff__sqlfluff-2846
- [ ] sqlfluff__sqlfluff-2849
- [ ] sqlfluff__sqlfluff-2862
- [ ] sqlfluff__sqlfluff-2907
- [ ] sqlfluff__sqlfluff-2998
- [ ] sqlfluff__sqlfluff-3066
- [ ] sqlfluff__sqlfluff-3109
- [ ] sqlfluff__sqlfluff-3170
- [ ] sqlfluff__sqlfluff-3220
- [ ] sqlfluff__sqlfluff-3330
- [ ] sqlfluff__sqlfluff-3354
- [ ] sqlfluff__sqlfluff-3411
- [ ] sqlfluff__sqlfluff-3435
- [ ] sqlfluff__sqlfluff-3436
- [ ] sqlfluff__sqlfluff-3608
- [ ] sqlfluff__sqlfluff-3648
- [ ] sqlfluff__sqlfluff-3662
- [ ] sqlfluff__sqlfluff-3700
- [ ] sqlfluff__sqlfluff-3904
- [ ] sqlfluff__sqlfluff-4041
- [ ] sqlfluff__sqlfluff-4043
- [ ] sqlfluff__sqlfluff-4051
- [ ] sqlfluff__sqlfluff-4084
- [ ] sqlfluff__sqlfluff-4151
- [ ] sqlfluff__sqlfluff-4753
- [ ] sqlfluff__sqlfluff-4764
- [ ] sqlfluff__sqlfluff-4777
- [ ] sqlfluff__sqlfluff-4778
- [ ] sqlfluff__sqlfluff-4834
- [ ] sqlfluff__sqlfluff-4997
- [ ] sqlfluff__sqlfluff-5074
- [ ] sqlfluff__sqlfluff-5170
- [ ] sqlfluff__sqlfluff-5206
