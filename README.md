# Package version CLI tool
> _Light weight tool written in bash for manage package versions in a semver manner._

## Installation

Via NPM

```shell
$ npm install --save-dev @orbit-online/package-version
```

<details>
<summary>or Yarn</summary>

```shell
$ npm install -D @orbit-online/package-version
```
</details>

Now add a script to package.json file like this for easy access:

```json
{
    "name": "myapp",
    ...
    "scripts": {
        "package-version": "package-version"
    }
}
```

The package-version tool can now be access using npm or Yarn respectively:

```shell
$ npm run package-version --help
```

```shell
$ yarn package-version --help
```

Alternatively you could install a task runner like [@orbit-online/create-task-runner](https://github.com/orbit-online/task-runner) that understands node_modules binaries and makes your own local scripts / tools easily accessible, under a common unified namespace.

## Usage

### Get current version of root package

Retrieving current version of the project (reading from the VERSION file of the package).

Consider the following filesystem structures: 

```
~/my-project/
 |- package/
   |- VERSION (content: 1.0.3-beta.2)
```

```
~/my-project/
 |- VERSION (content: 1.0.3-beta.2)
```

Via NPM
```shell
$ npm run package-version
my-project: 1.0.3-beta.2
$ npm run package-version 2> /dev/null
1.0.3-beta.2
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version
my-project: 1.0.3-beta.2
$ yarn package-version 2> /dev/nul
1.0.3-beta.2
```
</details>

### Get current version of named package (multiple packages)

Retrieving current version of a named package.

Consider the following filesystem structure: 

```
~/my-project/
  |- packages/
    |- create-my-project/
      |- VERSION (content: 1.6.2)
    |- my-project/
      |- VERSION (content: 3.1.4)
```

Via NPM
```shell
$ npm run package-version create-my-project
create-my-project: 1.6.1
$ npm run package-version create-my-project 2> /dev/null
1.6.1
$ npm run package-version my-project
my-project: 3.1.4
$ npm run package-version my-project 2> /dev/null
3.1.4
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version create-my-project
create-my-project: 1.6.1
$ yarn package-version create-my-project 2> /dev/null
1.6.1
$ yarn package-version my-project
my-project: 3.1.4
$ yarn package-version my-project 2> /dev/null
3.1.4
```
</details>

### Bump patch version

Bump package to next patch version.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3)
```

Via NPM
```shell
$ npm run package-version patch
Bumped the version of my-project from 1.2.3 -> 1.2.4
Wrote the changes back to the VERSION file, committed the changes with the message:

Release: v1.2.4

tagged the commit with:

v1.2.4

Don't forget to push both the branch and the tag e.g. by running:

$ git push && git push --tags
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version patch
Bumped the version of my-project from 1.2.3 -> 1.2.4
Wrote the changes back to the VERSION file, committed the changes with the message:

Release: v1.2.4

tagged the commit with:

v1.2.4

Don't forget to push both the branch and the tag e.g. by running:

$ git push && git push --tags
```
</details>

### Bump minor version

Bump package to next minor version.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3)
```

Via NPM
```shell
$ npm run package-version minor
Bumped the version of my-project from 1.2.3 -> 1.3.0
Wrote the changes back to the VERSION file, committed the changes with the message:

Release: v1.3.0

tagged the commit with:

v1.3.0

Don't forget to push both the branch and the tag e.g. by running:

$ git push && git push --tags
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version minor
Bumped the version of my-project from 1.2.3 -> 1.3.0
Wrote the changes back to the VERSION file, committed the changes with the message:

Release: v1.3.0

tagged the commit with:

v1.3.0

Don't forget to push both the branch and the tag e.g. by running:

$ git push && git push --tags
```
</details>

### Bump major version

Bump package to next major version.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3)
```

Via NPM
```shell
$ npm run package-version major
Bumped the version of my-project from 1.2.3 -> 2.0.0
Wrote the changes back to the VERSION file, committed the changes with the message:

Release: v2.0.0

tagged the commit with:

v2.0.0

Don't forget to push both the branch and the tag e.g. by running:

$ git push && git push --tags
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version major
Bumped the version of my-project from 1.2.3 -> 2.0.0
Wrote the changes back to the VERSION file, committed the changes with the message:

Release: v2.0.0

tagged the commit with:

v2.0.0

Don't forget to push both the branch and the tag e.g. by running:

$ git push && git push --tags
```
</details>

### Pre release

#### Bump alpha

Bump package to next alpha version.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3-alpha.1)
```

Via NPM
```shell
$ npm run package-version alpha
Bumped the version of package-version from 1.2.3-alpha.1 -> 1.2.3-alpha.2
...
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version alpha
Bumped the version of package-version from 1.2.3-alpha.1 -> 1.2.3-alpha.2
...
```
</details>

<details>
<summary>Error: Cannot bump from non pre-release to an alpha version without version bump</summary>

```
~/my-project/
 |- package/
   |- VERSION (content: 1.0.0)
```

```shell
$ npm run package-version alpha
Cannot bump alpha pre-release from a non-pre-release without bumping version number as well.
e.g. by running:
package-version minor alpha
```
</details>

<details>
<summary>Error: Only bumping to same or higher version suffix order is allowed</summary>

```
~/my-project/
 |- package/
   |- VERSION (content: 1.0.0-beta.2)
```

```shell
$ npm run package-version alpha
Cannot bump pre-release from beta to alpha
Only bumping to same or higher version suffix order is allowed.
```
</details>

#### Bump beta

Bump package to next beta version.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3-alpha.3)
```

Via NPM
```shell
$ npm run package-version beta
Bumped the version of package-version from 1.2.3-alpha.3 -> 1.2.3-beta.1
...
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version beta
Bumped the version of package-version from 1.2.3-alpha.3 -> 1.2.3-beta.1
...
```
</details>

<details>
<summary>Error: Cannot bump from non pre-release to an beta version without version bump</summary>

```
~/my-project/
 |- package/
   |- VERSION (content: 1.0.0)
```

```shell
$ npm run package-version beta
Cannot bump beta pre-release from a non-pre-release without bumping version number as well.
e.g. by running:
package-version minor beta
```
</details>

<details>
<summary>Error: Only bumping to same or higher version suffix order is allowed</summary>

```
~/my-project/
 |- package/
   |- VERSION (content: 1.0.0-rc.1)
```

```shell
$ npm run package-version beta
Cannot bump pre-release from rc to beta
Only bumping to same or higher version suffix order is allowed.
```
</details>

#### Bump RC

Bump package to next beta version.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3-beta.2)
```

Via NPM
```shell
$ npm run package-version rc
Bumped the version of package-version from 1.2.3-beta.2 -> 1.2.3-rc.1
...
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version rc
Bumped the version of package-version from 1.2.3-beta.2 -> 1.2.3-rc.1
...
```
</details>

<details>
<summary>Error: Cannot bump from non pre-release to an rc version without version bump</summary>

```
~/my-project/
 |- package/
   |- VERSION (content: 1.0.0)
```

```shell
$ npm run package-version rc
Cannot bump rc pre-release from a non-pre-release without bumping version number as well.
e.g. by running:
package-version minor rc
```
</details>

#### Release from pre-release

Stripping the pre-release suffix.

```
~/my-project/
 |- package/
   |- VERSION (content: 1.2.3-rc.2)
```

Via NPM
```shell
$ npm run package-version release
Bumped the version of package-version from 1.2.3-rc.2 -> 1.2.3
...
```

<details>
<summary>or Yarn</summary>

```shell
$ yarn package-version release
Bumped the version of package-version from 1.2.3-rc.2 -> 1.2.3
...
```
</details>

## Configuration

| Environment variable   | Default value                                                  | Description |
| :--------------------- | :------------------------------------------------------------- | :---------- |
| `PROJECT_PATH`         | `""`                                                           | The variable controls what the package-version executable considers the root path of the project, all relative paths interpreted of this tool will resolve them from the the root path. |
| `PACKAGE_VERSION_PATH` | `$PROJECT_PATH: $PROJECT_PATH/package: $PROJECT_PATH/packages` | A variable controlling search paths for `VERSION` files delimited by a `:` in same manner as the global `PATH` environment variable. |