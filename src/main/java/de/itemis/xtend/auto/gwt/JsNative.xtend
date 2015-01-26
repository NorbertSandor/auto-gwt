package de.itemis.xtend.auto.gwt

import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.file.Path

@Active(JsNativeProcessor)
annotation JsNative {
}

class JsNativeProcessor extends AbstractMethodProcessor {
	
	override doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {
		annotatedMethod.native = true
		annotatedMethod.final = true
		val sourceMethod = annotatedMethod.primarySourceElement as MethodDeclaration 
		if (sourceMethod.returnType == null) {
			annotatedMethod.addError("A JsNative method needs to explicitly specify a return type.")
			return;
		}
		// generate marker code
		annotatedMethod.body = '''
			«getUniqueMarkerCode(annotatedMethod.primarySourceElement as MethodDeclaration)»
		'''
	}
	
	private def String getUniqueMarkerCode(MethodDeclaration method) {
		return method.declaringType.simpleName+"#"+method.simpleName+"("+method.parameters.map[type].join(',')+")"
	}
		
	override doGenerateCode(MethodDeclaration annotatedMethod, extension CodeGenerationContext context) {
		val path = annotatedMethod.declaringType.getTargetPath(context)
		val contents = path.contents.toString
		val markerStart = contents.indexOf(getUniqueMarkerCode(annotatedMethod))
		val startIndex = contents.substring(0, markerStart).lastIndexOf('{')
		val endIndex = contents.substring(markerStart).indexOf('}') + markerStart
		val jsCode = annotatedMethod.body.toString.trimTripleQuotes
		path.contents = contents.substring(0, startIndex)+"/*-{"+jsCode+"}-*/;"+contents.substring(endIndex+1)
	}
	
	private def String trimTripleQuotes(String s) {
		s.substring(3, s.length-3)
	}
	
	def Path getTargetPath(TypeDeclaration type, extension CodeGenerationContext ctx) {
		val unit = type.compilationUnit
		val targetFolder = unit.filePath.targetFolder
		return targetFolder.append(type.qualifiedName.replace('.','/')+".java")
	}
}