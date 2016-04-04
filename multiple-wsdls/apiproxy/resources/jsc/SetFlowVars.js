// needed for apiproduct.name to get populated after access token verification
context.setVariable("flow.resource.name", context.getVariable("proxy.pathsuffix"));

