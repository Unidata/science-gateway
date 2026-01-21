# Merge all the dependencies for each environment. Manually inspect the
# resulting environment to remove/handle duplicates and conflicting versions

let deps = [
  cybertraining.yaml
  standard_environment.yaml
  metpy_cookbook.yaml
  metpy_thebook.yaml
  python_awips.yaml
]
| each {|| open $in | get dependencies }
| flatten
| uniq
| sort

{
  name: sunyo26s
  channels: [ conda-forge ]
  dependencies: $deps
}
| save environment.yml
