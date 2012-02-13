goog.provide('webglmaps.VertexAttrib');

goog.require('goog.asserts');
goog.require('webglmaps.GLObject');



/**
 * @constructor
 * @extends {webglmaps.GLObject}
 * @param {string} name Name.
 */
webglmaps.VertexAttrib = function(name) {

  goog.base(this);

  /**
   * @private
   * @type {string}
   */
  this.name_ = name;

  /**
   * @private
   * @type {number}
   */
  this.location_ = -1;

};
goog.inherits(webglmaps.VertexAttrib, webglmaps.GLObject);


/**
 */
webglmaps.VertexAttrib.prototype.enableArray = function() {
  var gl = this.getGL();
  goog.asserts.assert(this.location_ != -1);
  gl.enableVertexAttribArray(this.location_);
};


/**
 * @param {number} size Size.
 * @param {number} type Type.
 * @param {boolean} normalize Normalized.
 * @param {number} stride Stride.
 * @param {number} offset Offset.
 */
webglmaps.VertexAttrib.prototype.pointer =
    function(size, type, normalize, stride, offset) {
  var gl = this.getGL();
  goog.asserts.assert(this.location_ != -1);
  gl.vertexAttribPointer(
      this.location_, size, type, normalize, stride, offset);
};


/**
 * @param {WebGLRenderingContext} gl GL.
 */
webglmaps.VertexAttrib.prototype.setGL = function(gl) {
  this.location_ = -1;
  goog.base(this, 'setGL', gl);
};


/**
 * @param {WebGLProgram} program Program.
 */
webglmaps.VertexAttrib.prototype.setProgram = function(program) {
  if (goog.isNull(program)) {
    this.location_ = -1;
  } else {
    var gl = this.getGL();
    this.location_ = gl.getAttribLocation(program, this.name_);
    goog.asserts.assert(!goog.isNull(this.location_));
  }
};
