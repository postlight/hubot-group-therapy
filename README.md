# Hubot Group Therapy for Flowdock

Analyze users in a Flowdock thread using sentiment (https://github.com/thisandagain/sentiment)

## Installation

In hubot project repo, run:

```
npm install hubot-group-therapy --save
```

Then add **hubot-group-therapy** to your `external-scripts.json`:

```javascript
[
  "hubot-group-therapy"
]
```

## Hubot Commands

```
hubot group therapy
```

## Sample Output
Fred is 😐  
Thomas is 😭 `wtf, negative, alone, ill, awful, bad`  
Mike is 😄 `haha`  
Alice is 😐  
Betty is 😃 `amusement, haha, sweet, pretty`  
Frank is 😭 `hate`  
Roger is 😭 `confused, sad, romance, unclear, kind, weird`  
Jessica is 😃 `indifference, convinced, pretty, like, fun`  
Kevin is 😃 `joy, delight, happy, excited, yes, wow, amazing`  
  
Overall, everyone is 😃
