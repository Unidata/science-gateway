# Usage Monitoring

For usage run `usage_monitoring.py` without any arguments.

# Dependencies

Most dependencies are part of the python standard library (i.e. `json`, `cvs`,
`os`, etc.). Create a conda environment with the necessary additional
dependencies with:

`conda env update -f environment.yml`

# Cron

To collect usage data on a daily basis, run this as a cron job by adding this
to your `crontab`.

To collect usage data on a daily basis, run the wrapper script (which sets the
appropriate env variables) as a cron job by adding this to your `crontab`.

```shell
@daily bash /path/to/usage_monitoring.sh
```

For more fine grained scheduling, see `man 5 crontab`.
