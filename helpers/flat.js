const fs = require('fs');

const base = __dirname + '/../';
const filePath = base + '/contracts/';
const node = require('app-root-dir').get() + '/node_modules/';

const rxImport = /import ['"](.*?)['"];/gi;
const rxName = /\w*\.sol$/;
const rxRemove = /pragma solidity .*?;/;

function getFile(fileName, rel, imported) {
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
    return getFile(p1, path.replace(rxName, ''), imported).content.replace(rxRemove, '')
  });

  imported[name] = {
    content, fileName, name
  };

  return imported[name]
}

module.exports = (contract) => {
  return getFile('./' + contract, filePath, {}).content.replace(/\n+/g, '\n');
};