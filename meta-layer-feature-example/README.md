# meta-layer-feature-example

This Yocto / OpenEmbedded layer is an example template for the creation of new *feature* layers. A *feature* layer in this context is a layer which is not a Distro, Machine, or pure software layer, but tends toward altering behavior or enabling additional functionality. Per Yocto guidelines, it's best for a layer to not alter behavior just by including it in `BBLAYERS`, so everything in the layer needs to be conditional on enabling the *feature*. This example eases adding the feature to `OVERRIDES` only when it's applied, in a way that minimizes the performance impact (we don't add inline python to `OVERRIDES` to avoid adding to the variable expansion overhead).

## Usage

Copy classes/layer_overrides.bbclass to your *feature* layer and edit your conf/layer.conf in the way that the conf/layer.conf is used in this layer, then you may use the `feature-yourfeature` override in your recipes, appends, config files, and classes.
