[@react.component]
let make = (~src, ~width=2., ~height=2., ~title: string=?, ~alt: string=?) => {
  <img
    src
    title
    alt
    className={Css.merge([
      Css.style([
        Css.height(`rem(height)),
        Css.width(`rem(width)),
        Css.display(`flex),
        Css.justifyContent(`center),
        Css.alignItems(`center),
        Css.marginLeft(`rem(0.5)),
        Css.marginRight(`rem(0.5)),
        Css.position(`relative),
        Css.top(`px(1)),
      ]),
    ])}
  />;
};
