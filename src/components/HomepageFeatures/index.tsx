import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<'svg'>>;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Software Language',
    Svg: require('@site/static/img/frontend.svg').default,
    description: (
      <>
          Golang TypeScript
      </>
    ),
  },
  {
    title: 'Software Ecosystem',
    Svg: require('@site/static/img/backend.svg').default,
    description: (
      <>
          Microservices
      </>
    ),
  },
  {
    title: 'Software engineering',
    Svg: require('@site/static/img/devops.svg').default,
    description: (
      <>
          Cloud Native
      </>
    ),
  },
];

function Feature({title, Svg, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
      <>
        <summary className={styles.summary}>
            <p>Tech stack</p>
        </summary>
        <section className={styles.features}>
            <div className="container">
                <div className="row">
              {FeatureList.map((props, idx) => (
                <Feature key={idx} {...props} />
              ))}
            </div>
          </div>
        </section>
      </>
  );
}
