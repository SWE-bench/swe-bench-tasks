We have to be careful in deciding what is a "good" and a "bad" code. However I agree that we can avoid some mistakes, notably the confusion between IETF language tags [1] and ISO/IEC 15897 (Posix) [2] codes generally expected by Django. [1] ​https://en.wikipedia.org/wiki/IETF_language_tag [2] ​https://en.wikipedia.org/wiki/Locale_(computer_software)
​PR
​PR
I think I would still output a warning when a language code is normalized, just to inform the user that its input has been corrected.
Warning added when a language code is normalized.
Trying to coerce any input to something like a ​language tag only to hack it back to a ​locale using to_locale() feels like a kludge. It would be better to improve documentation.
Improving documentation is welcome, but silently accepting a wrong language code also look a bit suspicious. I think I would be happy with a warning without coercing anything.
We definitely need to improve the documentations. Coercing the language code is something we have to take call on.
Replying to Claude Paroz: Improving documentation is welcome, but silently accepting a wrong language code also look a bit suspicious. I think I would be happy with a warning without coercing anything. I agree. I think a warning would make sense, without coercion. It is still possible to provide a locale to makemessages where there are no actual message catalogs in any of the paths in settings.LOCALE_PATHS. We should probably scrap all the normalization stuff and just output a warning message if a locale specified by the user is not in all_locales. At the moment we output a "processing locale xx_XX" message if verbosity > 0 which should be fixed to only happen for valid, existing locales. As an aside, this is checking --locale for makemessages, but what about compilemessages? (And are their any others?)
Now I am thinking more to avoid the coercing and to put just a warning message.
Tim Current implementation involved just adding the warning message. We are not normalizing locale now.
Tim, I would like to understand better what needs to be done next ?
As commented on the pull request, you cannot use the all_locales variable as a reference as it does not contain new (valid) language codes. The modified test in your patch shows a 'Invalid locale en' message which is obviously wrong, isn't it? You may try using the django.utils.translation.trans_real.language_code_re to check the locale code syntax.
Hi Vishvajit! Are you still working on the bug? Do you need any help?
Hi Sanyam, Yes, I am working on this ticket but your help would be very appreciated.
Hi, Here my thoughts: language_code_re gets 'pt_BR'. And it does not get 'ZH-CN'. I did this: r'[a-z]{2}(_[A-Z]{2})?' It seems to work. But one test prints: System check identified no issues (0 silenced). Invalid locale d Invalid locale e ................................................. ---------------------------------------------------------------------- Ran 49 tests in 1.425s OK I did a check and there is only one line - 740 - that's use locale=LOCALE. All others use locale=[LOCALE]. What do you think Mark?
I forgot to say that the regrex I sent fails to: ja_JP_JP no_NO_NY th_TH_TH
I'm going to de-assign this because there's been progress, so that someone looking can pick it up.
Can I claim this? I think I can move this forward
Hi Manav, please do, no need to ask (but can I advise that you take just one at a time to begin :)
Can we use LANG_INFO from django.conf.locale in order to solve the conflict and raise the warning or as an alternative of language_code_re? If yes, then please confirm so that I may submit a patch, and also please suggest some way to use the same. OR We could even use the regex from language_code_re which is re.compile(r'^[a-z]{1,8}(?:-[a-z0-9]{1,8})*(?:@[a-z0-9]{1,20})?$', re.IGNORECASE) to solve the conflict and raise the warning. Please suggest the best option to work on, for the patch.
The problem with using LANG_INFO is that you exclude some extra languages added specifically for a project. You can try to use language_code_re, but you'll have to take into account the language code vs locale code difference.