In my opinion, this is caused by selecting the wrong python codec corresponding to 'ISO 2022 IR 159'. In the current implementation,  'iso-2022-jp' is used if 'ISO 2022 IR 159' is passed. But 'iso-2022-jp' is alias to 'iso200_jp'. I think we have to use 'iso-2022-jp-2'. It contains all 'iso-2022-jp' characters and 'ISO 2022 IR 159' characters.

If you don't mind, please assign this issue to me. I will make a PR for this issue.
Sure, go ahead! And thanks for the support!