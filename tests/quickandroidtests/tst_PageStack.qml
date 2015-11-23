import QtQuick 2.0
import QtTest 1.0
import QuickAndroid 0.1
import QuickAndroid.Private 0.1

Rectangle {
    id: window
    width : 480
    height : 640

    TestCase {
        id: testCase
        name: "PageStackTests"
        when : windowShown

        Component {
            id: pageStackCreator1

            PageStack {
                anchors.fill: parent
                property var pushedList: new Array

                property var poppedList: new Array

                onPushed: pushedList.push(page);
                onPopped: poppedList.push(page);

                initialPage: Page {
                    objectName: "InitialPage"

                    property int appearCount: 0
                    property int disappearCount: 0

                    Text {
                        anchors.centerIn: parent
                        text: "Initial Page"
                    }

                    onAppear: appearCount++;
                    onDisappear: disappearCount++;
                }

            }
        }

        Component {
            id: page1
            Page {
                objectName: "Page1"
                property int appearCount: 0

                Text {
                    anchors.centerIn: parent
                    text: "Page 1"
                }
                onAppear: appearCount++;

            }
        }

        function test_preview() {
            var stack = pageStackCreator1.createObject(window);
            var initialPage = Testable.search(stack,"InitialPage");
            var pushAnimFinished = false;
            compare(initialPage.appearCount,1);
            compare(stack.pushedList.length,1);
            compare(stack.poppedList.length,0);

            stack.pop(); // It will do nothing
            compare(stack.count,1);
            compare(stack.pushedList.length,1);
            compare(stack.poppedList.length,0);

            var p1 = stack.push(page1);
            p1._transition.presentTransition.onStopped.connect(function() {
                pushAnimFinished = true;
            });
            compare(stack.count,2);
            compare(stack.pushedList.length,2);
            compare(stack.poppedList.length,0);
            compare(p1.appearCount,0);
            compare(initialPage.appearCount,1);
            compare(initialPage.disappearCount,0);
            compare(stack.topPage,p1);

            wait(500);
            compare(pushAnimFinished,true);
            compare(initialPage.appearCount,1);
            compare(initialPage.disappearCount,1);
            compare(stack.topPage,p1);
            compare(p1.appearCount,1);

            stack.pop();
            compare(stack.count,1);
            compare(p1.appearCount,1);
            compare(stack.pushedList.length,2);
            compare(stack.poppedList.length,1);
            compare(initialPage.appearCount,1);
            compare(initialPage.disappearCount,1);
            wait(500);
            // p1 is destroyed.
            compare(initialPage.appearCount,2);
            compare(initialPage.disappearCount,1);

            wait(TestEnv.waitTime);
            stack.destroy();
        }

        function test_noHistory() {
            var stack = pageStackCreator1.createObject(window);
            var initialPage = Testable.search(stack,"InitialPage");
            compare(initialPage.appearCount,1);

            var p1 = page1.createObject(window);
            var p2 = page1.createObject(window);
            p1.noHistory = true;

            compare(stack.pages.length,1);
            stack.push(p1,{},false);
            compare(stack.pages.length,2);
            stack.push(p2,{},false);
            compare(stack.pages.length,2);
            stack.destroy();
        }

        function test_present() {
            var stack = pageStackCreator1.createObject(window);
            var initialPage = Testable.search(stack,"InitialPage");
            compare(initialPage.stack,stack);
            compare(initialPage.appearCount,1);
            compare(stack.count,1);

            var p1 = initialPage.present(page1,{},false)
            compare(stack.pages.length,2);
            compare(stack.count,2);

            p1.dismiss(false);
            compare(stack.count,1);
            stack.destroy();
        }

        Component {
            id: component2
            PageStack {
                initialPage: Page {
                    noHistory: true

                    Overlay {
                    }
                }
            }
        }

        function test_noHistory_initialPage() {
            var stack = component2.createObject(window);
            compare(stack.count,1);
            var p1 = stack.push(page1,{});
            compare(stack.count,1);
            compare(stack.topPage,p1);
            stack.destroy();
        }

        Component {
            id: itemCreator;
            Item {

            }
        }

        function test_error() {
            var stack = pageStackCreator1.createObject(window);
            stack.push(itemCreator);
        }
    }

}
