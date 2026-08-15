also tried `-o="junit_family=xunit2"`
Hi @nazariydolfin, thanks for posting.

Can you point out where that violates the schema? We are using https://github.com/jenkinsci/xunit-plugin/blob/master/src/main/resources/org/jenkinsci/plugins/xunit/types/model/xsd/junit-10.xsd IIRC. 
Hi, I require a schema like this:

```
<?xml version="1.0" encoding="UTF-8"?>
<testsuites disabled="" errors="" failures="" name="" tests="" time="">
    <testsuite disabled="" errors="" failures="" hostname="" id=""
               name="" package="" skipped="" tests="" time="" timestamp="">
        <properties>
            <property name="" value=""/>
        </properties>
        <testcase assertions="" classname="" name="" status="" time="">
            <skipped/>
            <error message="" type=""/>
            <failure message="" type=""/>
            <system-out/>
            <system-err/>
        </testcase>
        <system-out/>
        <system-err/>
    </testsuite>
    <testsuite ...>
       ...
    </testsuite>
    ...
</testsuites>
```
Is there a special set up that I need to implement in tests perhaps for it to generate the .xml report in the above format?

Because I can see that the `<testsuites>` is defined in your link.
> Is there a special set up that I need to implement in tests perhaps for it to generate the .xml report in the above format?

Unfortunately it seems we don't fully conform with the schema. Not sure how it works though, Jenkins seems to expect that schema and doesn't complain, but it is clear the root of the schema should be `<testsuites>`, not `<testsuite>`.

Perhaps @jhunkeler has a comment?
Found another related comment: https://github.com/pytest-dev/pytest/issues/1126#issuecomment-446906944, specially:

> The main thing I find missing in the currently output XML is that the top-level testsuites (plural!) tag is missing. The Schema **allows** for that and ...

(emphasis mine)

This would explain why the current format is accepted by many tools then.

cc @ringods
@nazariydolfin took the liberty to update the issue title now that the problem is more clear, hope that's OK.
Is there an easy hack around this? A workaround on the user side.
https://github.com/pytest-dev/pytest/blob/64a63652278d43b99aec5b5a3f36afd220b01f90/src/_pytest/junitxml.py#L661

The modifications I made a while back only extended what was already there, so I'm not surprised the outer level `<testsuites>` isn't supported. As you can see above `JUnit.testsuite(...)` (no `s`) populates the `<testsuite>` element. So judging from the code I'd say this module never supported generating `<testsuites>`.

I'll take a closer look at this tonight.
Hi @jhunkeler, how is it looking with this?