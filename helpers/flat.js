const fs = require('fs');

const base = require('app-root-dir').get();
const filePath = base + '/contracts/';
const node = base + '/node_modules/';

const rxImport = /import ['"](.*?)['"];/gi;
const rxName = /\w*\.sol$/;
const rxRemove = /pragma solidity .*?;/;

let imported = {};

function getFile(fileName, rel) {
  let name = fileName.match(rxName)[0];
  if (imported[name]) {
    return {
      content: ''
    };
  }
  let path = node + fileName;
  if (fileName[0] === '.') {
    path = rel + fileName
  }

  let content = fs.readFileSync(path).toString();
  content = content.replace(rxImport, (m, p1) => {
    return getFile(p1, path.replace(rxName, '')).content.replace(rxRemove, '')
  });

  imported[name] = {
    content, fileName, name
  };

  return imported[name]
}

module.exports = (contract) => {
  return getFile('./' + contract, filePath).content.replace(/\n+/g, '\n');
};