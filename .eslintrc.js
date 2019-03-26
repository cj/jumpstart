module.exports = {
  extends: ['react-app', 'plugin:jsx-a11y/recommended', 'airbnb', 'prettier'],
  plugins: ['jsx-a11y', 'react-hooks', 'lint-erb'],
  env: {
    browser: true,
    jquery: true,
    node: true,
    commonjs: true,
    es6: true,
  },
  globals: {
    Rails: true,
    Turbolinks: true,
    I18n: true,
  },
  overrides: [
    {
      files: ['jest/**'],
      rules: {
        'import/no-extraneous-dependencies': 'off',
      },
    },
    {
      files: ['**/*.ts', '**/*.tsx', '**/*.d.ts'],
      rules: {
        'no-unused-vars': ['off'],
        'no-undef': ['off'],
      },
      parser: '@typescript-eslint/parser',
      settings: {
        'import/resolver': {
          typescript: {},
        },
      },
    },
  ],
  rules: {
    semi: ['error', 'never'],
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'global-require': 'off',
    'no-param-reassign': ['error', { props: false }],
    'spaced-comment': [
      'error',
      'always',
      {
        markers: ['/'],
      },
    ],
    'react/jsx-filename-extension': [
      'error',
      {
        extensions: ['.jsx', '.tsx'],
      },
    ],
    'react/prop-types': 'off',
    'no-return-assign': 'off',
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    // 'react/no-this-in-sfc': 'off',
    'react/no-unknown-property': [
      'error',
      {
        ignore: ['class'],
      },
    ],
    'react/jsx-closing-tag-location': 'off',
    'react/jsx-curly-brace-presence': 'off',
    'react/jsx-one-expression-per-line': 'off',
    'react-hooks/rules-of-hooks': 'error',
  },
  settings: {
    'import/resolver': {
      alias: {
        map: [['', './app/javascript'], ['~', './app/javascript']],
        extensions: ['.js', '.jsx', '.ts', '.tsx', '.json', 'js.erb'],
      },
    },
  },
}
