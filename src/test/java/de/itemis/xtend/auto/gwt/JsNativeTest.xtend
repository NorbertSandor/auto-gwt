package de.itemis.xtend.auto.gwt

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

class JsNativeTest {

	extension XtendCompilerTester compiler = XtendCompilerTester.newXtendCompilerTester(JsNativeTest)

	@Test def void testSimple() {
		'''
			import «JsNative.name»
			
			class C /* extends JavaScriptObject */ {
			  protected new() {
			  }
			
			  @JsNative
			  def void a() '«»''
			    this.a();
			  '«»''
			
			  @JsNative
			  def void b() '«»''
			    this.b();
			  '«»''
			}
		'''.assertCompilesTo('''
			import de.itemis.xtend.auto.gwt.JsNative;
			
			@SuppressWarnings("all")
			public class C {
			  protected C() {
			  }
			
			  @JsNative
			  public final native void a() /*-{
			    this.a();
			  }-*/;
			
			  @JsNative
			  public final native void b() /*-{
			    this.b();
			  }-*/;
			}
		''')
	}
}
