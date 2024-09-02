process.chdir('./');
const gulp = require('gulp');
const sass = require('gulp-sass')(require('sass'));
const cleanCSS = require('gulp-clean-css');
const concat = require('gulp-concat');
const browserSync = require('browser-sync').create();
const minify = require('gulp-minify');

// Define the paths for your application
const paths = {
  srcScss: './src/scss/*.scss',
  destScss: './assets/css/'
};

function scripts () {
  return gulp.src('modules/misc/*.js')
      .pipe(minify({
          ext: {
              min: '.min.js'
          },
          ignoreFiles: ['-min.js']
      }))
      .pipe(gulp.dest('modules/_min'))
}
gulp.task('min-js', function() {
  // return gulp.src('_modules/master/*.js')
  //     .pipe(minify({
  //         ext: {
  //             min: '.min.js'
  //         },
  //         ignoreFiles: ['-min.js']
  //     }))
  //     .pipe(gulp.dest('_modules/_min'))
});

// Compile SCSS and concatenate into a single file
gulp.task('compile-scss', function () {
  return gulp.src(paths.srcScss) // Adjust the source directory as needed
    .pipe(sass().on('error', sass.logError))
    // .pipe(concat('style.css'))
    .pipe(gulp.dest(paths.destScss))
    .pipe(browserSync.stream());
});

// Gulp task to minify CSS
gulp.task('minify-css', function () {
  return gulp.src(paths.destScss + '/*.css')
    .pipe(cleanCSS())
    .pipe(gulp.dest(paths.destScss))
    .pipe(browserSync.stream()); // Soft reload CSS changes;
});

// Task to serve the Vue app using BrowserSync
function serve() {
  // Serve files from the root directory of your Vue project
//   browserSync.init({
//     server: {
//       baseDir: './',
//     },
//   });

  browserSync.init({
    proxy: 'localhost/xsibambo/' // Update with your CodeIgniter app's local URL
  });

  gulp.watch('modules/misc/*.js', scripts); 
  // Watch for changes in Vue app files and reload the browser
  gulp.watch('**/*.js').on('change', browserSync.reload);
  gulp.watch('**/*.vue').on('change', browserSync.reload);
  gulp.watch('**/*.html').on('change', browserSync.reload);
  gulp.watch('**/*.css').on('change', browserSync.stream);

  gulp.watch(paths.srcScss, gulp.series('compile-scss', 'minify-css'));
  gulp.watch('./assets/css/*.css').on('change', browserSync.stream);
  
}

// Default task
exports.default = serve;
