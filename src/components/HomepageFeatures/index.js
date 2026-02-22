"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = HomepageFeatures;
var clsx_1 = require("clsx");
var Heading_1 = require("@theme/Heading");
var styles_module_css_1 = require("./styles.module.css");
var FeatureList = [
    {
        title: 'Software Language',
        Svg: require('@site/static/img/frontend.svg').default,
        description: (<>
          Golang TypeScript
      </>),
    },
    {
        title: 'Software Ecosystem',
        Svg: require('@site/static/img/backend.svg').default,
        description: (<>
          Microservices
      </>),
    },
    {
        title: 'Software engineering',
        Svg: require('@site/static/img/devops.svg').default,
        description: (<>
          Cloud Native
      </>),
    },
];
function Feature(_a) {
    var title = _a.title, Svg = _a.Svg, description = _a.description;
    return (<div className={(0, clsx_1.default)('col col--4')}>
      <div className="text--center">
        <Svg className={styles_module_css_1.default.featureSvg} role="img"/>
      </div>
      <div className="text--center padding-horiz--md">
        <Heading_1.default as="h3">{title}</Heading_1.default>
        <p>{description}</p>
      </div>
    </div>);
}
function HomepageFeatures() {
    return (<>
        <summary className={styles_module_css_1.default.summary}>
            <p>Tech stack</p>
        </summary>
        <section className={styles_module_css_1.default.features}>
            <div className="container">
                <div className="row">
              {FeatureList.map(function (props, idx) { return (<Feature key={idx} {...props}/>); })}
            </div>
          </div>
        </section>
      </>);
}
