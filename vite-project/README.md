<p align="center">
  <a href="https://vitejs.dev" target="_blank" rel="noopener noreferrer">
    <img width="180" src="https://vitejs.dev/logo.svg" alt="Vite logo">
  </a>
</p>
<br/>
<p align="center">
  <a href="https://npmjs.com/package/vite"><img src="https://img.shields.io/npm/v/vite.svg" alt="npm package"></a>
  <a href="https://nodejs.org/en/about/previous-releases"><img src="https://img.shields.io/node/v/vite.svg" alt="node compatibility"></a>
  <a href="https://github.com/vitejs/vite/actions/workflows/ci.yml"><img src="https://github.com/vitejs/vite/actions/workflows/ci.yml/badge.svg?branch=main" alt="build status"></a>
  <a href="https://pr.new/vitejs/vite"><img src="https://developer.stackblitz.com/img/start_pr_dark_small.svg" alt="Start new PR in StackBlitz Codeflow"></a>
  <a href="https://chat.vitejs.dev"><img src="https://img.shields.io/badge/chat-discord-blue?style=flat&logo=discord" alt="discord chat"></a>
</p>
<br/>

# Vite ⚡ 

> 차세대 프런트엔드 툴링 

- 💡 즉각적인 서버 시작 
- ⚡️ 초고속 HMR 
- 🛠️ 풍부한 기능 
- 📦 최적화된 빌드 
- 🔩 범용 플러그인 인터페이스 
- 🔑 완전히 유형화된 API 

Vite(프랑스어로 "빠른"을 의미하며 [`/vit/`](https://cdn.jsdelivr.net/gh/vitejs/vite@main/docs/public/vite.mp3)로 발음하며 "veet"와 유사)는 프런트엔드 개발 경험을 크게 개선하는 새로운 종류의 프런트엔드 빌드 도구입니다. 이 도구는 두 가지 주요 부분으로 구성됩니다. 

- [네이티브 ES 모듈](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules)을 통해 소스 파일을 제공하는 개발 서버로, [풍부한 기본 제공 기능](https://vitejs.dev/guide/features.html)과 놀라울 정도로 빠른 [핫 모듈 교체(HMR)](https://vitejs.dev/guide/features.html#hot-module-replacement)가 포함되어 있습니다. 

- 프로덕션을 위해 고도로 최적화된 정적 자산을 출력하도록 미리 구성된 [Rollup](https://rollupjs.org)과 코드를 번들로 제공하는 [빌드 명령](https://vitejs.dev/guide/build.html). 

또한 Vite는 [플러그인 API](https://vitejs.dev/guide/api-plugin.html) 및 [JavaScript API](https://vitejs.dev/guide/api-javascript.html)를 통해 매우 확장 가능하며 전체 타이핑 지원이 제공됩니다. 

[자세한 내용은 문서를 읽어보세요](https://vitejs.dev).

## 패키지 

| 패키지 | 버전(변경 내역을 보려면 클릭하세요) | 
| ----------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| [vite](packages/vite)                           | [![vite version](https://img.shields.io/npm/v/vite.svg?label=%20)](packages/vite/CHANGELOG.md)                                    |
| [@vitejs/plugin-legacy](packages/plugin-legacy) | [![plugin-legacy version](https://img.shields.io/npm/v/@vitejs/plugin-legacy.svg?label=%20)](packages/plugin-legacy/CHANGELOG.md) |
| [create-vite](packages/create-vite)             | [![create-vite version](https://img.shields.io/npm/v/create-vite.svg?label=%20)](packages/create-vite/CHANGELOG.md)               |


## 기여 

[기여 가이드](CONTRIBUTING.md)를 참조하세요. 

## 라이선스 

[MIT](LICENSE). 

## 스폰서 

<p align="center"> 
  <a target="_blank" href="https://github.com/sponsors/yyx990803"> 
    <img alt="sponsors" src="https://sponsors.vuejs.org/vite.svg"> 
  </a> 
</p>



# React + TypeScript + Vite

Vite는 프레임워크도 아니고 라이브러리도 아닙니다. Vite는 주로 빌드 도구(build tool)로 분류됩니다. Vite는 개발 환경을 개선하고, 빠른 빌드와 효율적인 개발 서버를 제공하는 도구입니다. Vite는 다양한 프레임워크와 라이브러리와 함께 사용할 수 있으며, 특히 프론트엔드 개발에서 많이 사용됩니다.


## Vite의 주요 특징 ##


- **빠른 개발 서버**: Vite는 ES 모듈을 기반으로 한 빠른 개발 서버를 제공합니다. 이는 코드 변경 시 빠르게 반영되며, 개발 경험을 크게 향상시킵니다.

- **핫 모듈 교체(HMR)**: 코드 변경 시 페이지를 새로고침하지 않고도 변경 사항을 즉시 반영하는 HMR 기능을 제공합니다.

- **최적화된 빌드**: Vite는 Rollup을 사용하여 최적화된 빌드를 생성합니다. 이는 프로덕션 환경에서의 성능을 향상시킵니다.

- **플러그인 시스템**: Vite는 다양한 플러그인을 통해 기능을 확장할 수 있습니다. 예를 들어, TypeScript, JSX, CSS 전처리기 등을 지원하는 플러그인이 있습니다.

- **프레임워크 독립적**: Vite는 특정 프레임워크에 종속되지 않으며, React, Vue, Svelte 등 다양한 프레임워크와 함께 사용할 수 있습니다.


## Vite의 역할 ##

**개발 서버**: Vite는 빠른 개발 서버를 제공하여 개발 중에 빠른 피드백을 받을 수 있게 합니다.
번들러: Vite는 Rollup을 사용하여 프로덕션 빌드를 생성합니다. 이는 코드 스플리팅, 트리 쉐이킹 등 다양한 최적화 기법을 적용합니다.
플러그인 시스템: Vite는 플러그인 시스템을 통해 다양한 기능을 확장할 수 있습니다. 이는 개발자가 필요에 따라 Vite의 기능을 커스터마이즈할 수 있게 합니다.

## Vite와 프레임워크의 차이점 ##

- **프레임워크**: 프레임워크는 애플리케이션의 구조와 흐름을 정의하고, 특정 패턴에 따라 개발을 진행하도록 돕는 도구입니다. 예를 들어, React, Vue, Angular 등이 프레임워크에 해당합니다.
- **라이브러리**: 라이브러리는 특정 기능을 제공하는 코드의 집합으로, 개발자가 필요에 따라 가져다 사용할 수 있습니다. 예를 들어, Lodash, Axios 등이 라이브러리에 해당합니다.
- **빌드 도구**: 빌드 도구는 개발 환경을 설정하고, 코드를 번들링하고, 최적화하는 역할을 합니다. Vite는 이러한 빌드 도구에 해당합니다.

## 요약 ##

Vite는 프레임워크도 아니고 라이브러리도 아닌 빌드 도구입니다. Vite는 빠른 개발 서버와 효율적인 빌드 시스템을 제공하여 개발 경험을 향상시키는 데 중점을 둡니다. 다양한 프레임워크와 함께 사용할 수 있으며, 플러그인 시스템을 통해 기능을 확장할 수 있습니다. Vite는 특히 프론트엔드 개발에서 많이 사용되며, 빠른 피드백과 최적화된 빌드를 제공하는 데 강점을 가지고 있습니다.

Vite를 사용하여 React와 TypeScript 프로젝트를 설정하는 것은 매우 간단합니다. Vite는 기본적으로 React와 TypeScript 템플릿을 제공하므로, 몇 가지 명령어만으로 프로젝트를 설정할 수 있습니다. 다음은 Vite를 사용하여 React와 TypeScript 프로젝트를 설정하는 단계별 가이드입니다.

## Vite 프로젝트 시작하기 

1. Vite 프로젝트 생성

먼저, Vite 프로젝트를 생성합니다. Vite는 npm, yarn, pnpm을 통해 설치할 수 있습니다. 여기서는 npm을 사용한 예제를 보여드리겠습니다.

``` bash
npm create vite@latest my-react-ts-app --template react-ts
```

위 명령어는 my-react-ts-app이라는 이름의 새로운 Vite 프로젝트를 생성하며, React와 TypeScript 템플릿을 사용합니다.

2. 프로젝트 디렉토리로 이동

프로젝트 디렉토리로 이동합니다.

``` bash
cd my-react-ts-app
```

3. 의존성 설치

프로젝트의 의존성을 설치합니다.
``` bash
npm install
```

4. 개발 서버 실행

개발 서버를 실행하여 프로젝트가 정상적으로 설정되었는지 확인합니다.

``` bash
npm run dev
```
5. 기본 파일 구조

프로젝트가 생성되면 기본 파일 구조는 다음과 같습니다:

my-react-ts-app/<br>
├── node_modules/<br>
├── public/<br>
│   └── vite.svg<br>
├── src/<br>
│   ├── App.css<br>
│   ├── App.tsx<br>
│   ├── index.css<br>
│   ├── main.tsx<br>
│   └── vite-env.d.ts<br>
├── .gitignore<br>
├── index.html<br>
├── package.json<br>
├── tsconfig.json<br>
└── vite.config.ts<br>

6. 주요 파일 설명

- src/main.tsx: React 애플리케이션의 진입점입니다.
- src/App.tsx: 기본 React 컴포넌트입니다.
- tsconfig.json: TypeScript 설정 파일입니다.
- vite.config.ts: Vite 설정 파일입니다.
- 
7. TypeScript 설정

기본적으로 Vite는 TypeScript 설정을 포함하고 있습니다. tsconfig.json 파일을 열어 TypeScript 설정을 확인하고, 필요에 따라 수정할 수 있습니다.

``` json
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": false,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
```
8. React 컴포넌트 작성

이제 src/App.tsx 파일을 열어 React 컴포넌트를 작성할 수 있습니다. 예를 들어, 간단한 컴포넌트를 작성해보겠습니다.
``` tsx
import React from 'react';

interface GreetingProps {
  name: string;
}

const Greeting: React.FC<GreetingProps> = ({ name }) => {
  return <h1>Hello, {name}!</h1>;
};

const App: React.FC = () => {
  return (
    <div>
      <Greeting name="World" />
    </div>
  );
};

export default App;
```

React와 TypeScript의 통합 예제

다음은 간단한 React 컴포넌트에 TypeScript를 적용한 예제입니다.

``` tsx
import React from 'react';

// Props 타입 정의
interface GreetingProps {
  name: string;
  age?: number; // 선택적 프로퍼티
}

// 함수형 컴포넌트에 타입 적용
const Greeting: React.FC<GreetingProps> = ({ name, age }) => {
  return (
    <div>
      <h1>Hello, {name}!</h1>
      {age && <p>You are {age} years old.</p>}
    </div>
  );
};

export default Greeting;
```

요약

위 단계를 따라 Vite를 사용하여 React와 TypeScript 프로젝트를 쉽게 설정할 수 있습니다. Vite는 빠른 개발 서버와 간단한 설정을 제공하여, React와 TypeScript를 사용하는 개발자에게 매우 유용한 도구입니다. 프로젝트를 설정한 후에는 TypeScript의 타입 시스템을 활용하여 더 안전하고 유지보수하기 쉬운 코드를 작성할 수 있습니다.



This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type aware lint rules:

- Configure the top-level `parserOptions` property like this:

```js
export default {
  // other rules...
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    project: ['./tsconfig.json', './tsconfig.node.json'],
    tsconfigRootDir: __dirname,
  },
}
```

- Replace `plugin:@typescript-eslint/recommended` to `plugin:@typescript-eslint/recommended-type-checked` or `plugin:@typescript-eslint/strict-type-checked`
- Optionally add `plugin:@typescript-eslint/stylistic-type-checked`
- Install [eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react) and add `plugin:react/recommended` & `plugin:react/jsx-runtime` to the `extends` list
