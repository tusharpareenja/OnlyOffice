/*
 * (c) Copyright Ascensio System SIA 2010-2024
 *
 * This program is a free software product. You can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License (AGPL)
 * version 3 as published by the Free Software Foundation.
 *
 * See full license details in the source header.
 */

const path = require('path');
const _ = require('lodash');

module.exports = function (grunt) {
  // ✅ Load package.json once and make it available everywhere
  const packageFile = grunt.file.readJSON('package.json');

  // ===============================
  // Addons merging logic
  // ===============================
  let addons = grunt.option('addon') || [];
  if (!Array.isArray(addons)) {
    addons = [addons];
  }

  addons.forEach((element, index, self) => (self[index] = path.join('..', element)));
  addons = addons.filter(element => grunt.file.isDir(element));

  function _merge(target, ...sources) {
    if (!sources.length) return target;
    const source = sources.shift();

    for (const key in source) {
      if (_.isObject(source[key])) {
        if (_.isArray(source[key])) {
          if (!_.isArray(target[key])) target[key] = [];
          target[key].push(...source[key]);
        } else {
          if (!target[key]) Object.assign(target, { [key]: {} });
          _merge(target[key], source[key]);
        }
      } else {
        Object.assign(target, { [key]: source[key] });
      }
    }
    return _merge(target, ...sources);
  }

  addons.forEach(element => {
    const _path = path.join(element, 'package.json');
    if (grunt.file.exists(_path)) {
      _merge(packageFile, require(_path));
      grunt.log.ok(`addon ${element} merged successfully`.green);
    }
  });

  // ===============================
  // Grunt Config
  // ===============================
  const checkDependencies = {};

  if (packageFile.npm) {
    for (const i of packageFile.npm) {
      checkDependencies[i] = {
        options: {
          install: true,
          continueAfterInstall: true,
          packageDir: i
        }
      };
    }
  }

  grunt.initConfig({
    clean: packageFile.grunt?.clean || {},
    mkdir: packageFile.grunt?.mkdir || {},
    copy: packageFile.grunt?.copy || {},
    comments: {
      js: {
        options: { singleline: true, multiline: true },
        src: packageFile.postprocess?.src || []
      }
    },
    usebanner: {
      copyright: {
        options: {
          position: 'top',
          banner:
            '/*\n' +
            ' * Copyright (C) ' +
            (process.env['PUBLISHER_NAME'] || '') +
            ' 2012-<%= grunt.template.today("yyyy") %>. All rights reserved\n' +
            ' *\n' +
            (process.env['PUBLISHER_URL'] || '') +
            '\n' +
            ' *\n' +
            ' * Version: ' +
            (process.env['PRODUCT_VERSION'] || '') +
            ' (build:' +
            (process.env['BUILD_NUMBER'] || '') +
            ')\n' +
            ' */\n',
          linebreak: false
        },
        files: { src: packageFile.postprocess?.src || [] }
      }
    },
    checkDependencies
  });

  grunt.registerTask('build-develop', 'Build develop scripts', () => {
    grunt.initConfig({
      copy: packageFile.grunt?.['develop-copy'] || {}
    });
  });

  // ===============================
  // Load plugins
  // ===============================
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-mkdir');
  grunt.loadNpmTasks('grunt-stripcomments');
  grunt.loadNpmTasks('grunt-banner');
  grunt.loadNpmTasks('grunt-check-dependencies');

  // ===============================
  // Register tasks
  // ===============================
  grunt.registerTask('default', ['clean', 'mkdir', 'copy', 'comments', 'usebanner', 'checkDependencies']);
  grunt.registerTask('build', ['default']);
  grunt.registerTask('develop', ['build-develop', 'copy']);
};
