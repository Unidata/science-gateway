# Usage Monitoring

## Dependencies

Create a conda environment with the necessary additional dependencies with:

`conda env update -f environment.yml`

## Usage

For usage run `python usage_monitoring.py`. When running this script, you will
need to `source` a valid `openrc.sh`.

See the [Jetstream2 docs](https://docs.jetstream-cloud.org/ui/cli/auth/) for
information on how to acquire an `openrc.sh` file.

### Activating the Environment

Activate your environment: `conda activate usage-monitoring` then run:
`python usage_monitoring.py [options]`

### Without Activating the Environment

If you would like to run the `usage_monitoring.py` script without activating the
environment, use `conda run`, as in `usage_monitoring.sh`:

`conda run -n usage-monitoring python usage_monitoring.py [options]`

# Cron

To collect usage data on a daily basis, run the wrapper script (after setting
the appropriate environment variables) as a cron job by adding this to your
`crontab`:

```shell
@daily bash /path/to/usage_monitoring.sh
```

For more fine grained scheduling, see `man 5 crontab`.
