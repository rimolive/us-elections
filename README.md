# US Elections dashboard

This tutorial will show a geo dashboard containing results from the past US elections. This project aims to show in the map the number of voters in each county in the past 3 presidential elections (2008, 2012 and 2016).

You can also deploy this app in OpenShift by following the suggestion in [Deploying on OpenShift](#deploying-on-openshift) section.

**Note**: It is still a work in progress.

## Deploying on OpenShift

To deploy on OpenShift, follow the instructions below:

* Add the Imagestream for R in your OpenShift project.

```
oc create -f https://raw.githubusercontent.com/rimolive/r-s2i-openshift/master/template.yaml
```

* Create a new application using this repo and the newest R Imagestream.

```
oc new-app r~https://github.com/rimolive/us-elections.git
```

* Add a new Environment Variable for us-elections DeploymentConfig to point to the application main script.

```
oc env dc/us-elections MAIN_FILE=app.R
```

* Expose the application endpoint.

```
oc expose svc/us-elections
```

## Future improvements

* Add a filter in the map section to show other election years
* Create a better palette to show the range of voters (currently the variance is high)